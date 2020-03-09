func findDependencyRegistrations(
    for key: DependencyKey,
    in resolvingContainer: DependencyContainer
) -> [RegistrationInfo] {
    for container in resolvingContainer.hierarchy {
        let registrations = container.registrationStorage.getRegistrations(for: key)

        guard !registrations.isEmpty else { continue }

        return registrations.map { registration in
            RegistrationInfo(registration: registration, owner: container)
        }
    }

    return []
}

func findAllRegistrations(
    for type: Any.Type,
    in resolvingContainer: DependencyContainer,
    target: ResolveMultipleInstancesSearchTarget
) -> [RegistrationInfo] {

    switch target {
    case .containerHierarchy:
        var result: [RegistrationInfo] = []
        for container in resolvingContainer.hierarchy {
            for (_, info) in container.registrationStorage.getAllRegistrations(for: type) {
                result.append(RegistrationInfo(registration: info, owner: container))
            }
        }

        return result

    case .nearestContainer:
        for container in resolvingContainer.hierarchy {
            let registrations = container.registrationStorage.getAllRegistrations(for: type)

            guard !registrations.isEmpty else { continue }

            return registrations.map { (name, info) in
                RegistrationInfo(registration: info, owner: container)
            }
        }

        return []
    }
}

func resolveRecursive<Dependency>(
    registrationInfo: RegistrationInfo,
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
        dependencyKey: registrationInfo.registration.dependencyKey,
        resolutionPlace: resolutionPlace)

    let instanceOwnerContainer = try registration.lifestyle.selectContainer(selectContainerArgs)

    let factory = registration.factory as! DependencyFactory<Dependency>

    if let storage = instanceOwnerContainer?.instanceStorage,
        let instance = factory.getFromStorage(storage) {
        return instance
    }

    let childResolver = Resolver(
        resolvingContainer: instanceOwnerContainer ?? resolvingContainer,
        executionQueue: queue
    )

    let result = try _do({
        try factory.createAndSaveIfNeeded(
            resolver: childResolver,
            storage: instanceOwnerContainer?.instanceStorage
        )
    }, finally: childResolver.dispose)

    for action in result.setUpActions {

        let stackItem = ResolvingStackItem(
            dependencyKey: registrationInfo.registration.dependencyKey,
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
