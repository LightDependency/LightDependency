func findDependencyRegistrations<Dependency>(
    ofType type: Dependency.Type,
    withName name: String?,
    in resolvingContainer: DependencyContainer)
    -> [RegistrationInfo<Dependency>] {
        for container in resolvingContainer.hierarchy {
            let registrations: [AnyDependencyRegistration<Dependency>]
                = container.registrationStorage.getRegistrations(withName: name)

            guard !registrations.isEmpty else { continue }

            return registrations.map { registration in
                RegistrationInfo(registration: registration, name: name, owner: container)
            }
        }

        return []
}

func findAllRegistrations<Dependency>(
    for type: Dependency.Type,
    in resolvingContainer: DependencyContainer,
    target: ResolveMultipleInstancesSearchTarget)
    -> [RegistrationInfo<Dependency>] {

        switch target {
        case .containerHierarchy:
            var result: [RegistrationInfo<Dependency>] = []
            for container in resolvingContainer.hierarchy {
                for (name, info) in container.registrationStorage.getAllRegistrations(for: Dependency.self) {
                    result.append(RegistrationInfo(registration: info, name: name, owner: container))
                }
            }

            return result

        case .nearestContainer:
            for container in resolvingContainer.hierarchy {
                let registrations = container.registrationStorage.getAllRegistrations(for: Dependency.self)

                guard !registrations.isEmpty else { continue }

                return registrations.map { (name, info) in
                    RegistrationInfo(registration: info, name: name, owner: container)
                }
            }

            return []
        }
}

func resolveRecursive<Dependency>(
    registrationInfo: RegistrationInfo<Dependency>,
    resolvingContainer: DependencyContainer,
    queue: ResolutionQueue,
    resolutionPlace: DebugInfo
) throws -> Dependency {

    try Diagnostics.validateResolutionQueue(queue.info, resolutionPlace)

    let registration = registrationInfo.registration
    let owner = registrationInfo.owner

    let selectContainerArgs = SelectContainerContext(
        resolvingContainer: resolvingContainer,
        registrationOwnerContainer: owner,
        queueInfo: queue.info,
        dependencyKey: registrationInfo.key,
        resolutionPlace: resolutionPlace)

    let instanceOwnerContainer = try registration.lifestyle.selectContainer(selectContainerArgs)

    if let storage = instanceOwnerContainer?.instanceStorage,
        let instance = registration.getFromStorage(storage) {
        return instance
    }

    let childResolver = Resolver(
        resolvingContainer: instanceOwnerContainer ?? resolvingContainer,
        executionQueue: queue
    )

    let result = try _do({
        try registration.createAndSaveIfNeeded(
            resolver: childResolver,
            storage: instanceOwnerContainer?.instanceStorage
        )
    }, finally: childResolver.dispose)

    for action in result.setUpActions {

        let stackItem = ResolvingStackItem(
            dependencyKey: registrationInfo.key,
            resolvingContainer: instanceOwnerContainer ?? resolvingContainer,
            registrationOwnerContainer: registrationInfo.owner,
            registrationPlace: registrationInfo.registration.debugInfo,
            resolutionPlace: resolutionPlace,
            setUpPlace: action.debugInfo
        )

        queue.async(item: stackItem) { queue in
            let resolver = Resolver(
                resolvingContainer: instanceOwnerContainer ?? resolvingContainer,
                executionQueue: queue
            )

            defer { resolver.dispose() }
            try action.setUp(resolver)
        }
    }

    return result.dependency
}
