func findDependencyRegistrations<Dependency>(
    ofType type: Dependency.Type,
    withName name: String?,
    in resolvingContainer: DependencyContainer)
    -> [RegistrationInfo<Dependency>] {
        for container in resolvingContainer.hierarchy {
            let registrations: [AnyDependencyRegistration<Dependency>]
                = container.registrationStore.getRegistrations(withName: name)

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
                for (name, info) in container.registrationStore.getAllRegistrations(for: Dependency.self) {
                    result.append(RegistrationInfo(registration: info, name: name, owner: container))
                }
            }

            return result

        case .nearestContainer:
            for container in resolvingContainer.hierarchy {
                let registrations = container.registrationStore.getAllRegistrations(for: Dependency.self)

                guard !registrations.isEmpty else { continue }

                return registrations.map { (name, info) in
                    RegistrationInfo(registration: info, name: name, owner: container)
                }
            }

            return []
        }
}

func resolveRecursive<Dependency>(
    stack: ResolvingStack,
    registrationInfo: RegistrationInfo<Dependency>,
    resolvingContainer: DependencyContainer,
    file: StaticString,
    line: UInt) throws
    -> Dependency {
        let registration = registrationInfo.registration
        let owner = registrationInfo.owner

        let stackItem = ResolvingStackItem(
            dependencyKey: registrationInfo.key,
            resolvingContainer: resolvingContainer,
            ownerContainer: owner,
            registrationPlace: registrationInfo.registration.debugInfo,
            resolutionPlace: DebugInfo(file: file, line: line))

        let newStack = stack.adding(stackItem)

        guard hierarchyDoesNotContainCircularDependencies(stack: stack, currentStackItem: stackItem) else {
            throw DependencyResolutionError(
                errorType: .recursiveDependencyFound,
                dependencyType: Dependency.self,
                dependencyName: registrationInfo.name,
                resolvingStack: newStack,
                file: file,
                line: line)
        }

        let selectContainerArgs = SelectContainerContext(
            resolvingContainer: resolvingContainer,
            registrationOwnerContainer: owner,
            resolvingStack: newStack,
            dependencyKey: registrationInfo.key,
            file: file,
            line: line)

        let containerForInstanceStoring = try registration.lifestyle.selectContainer(selectContainerArgs)

        if let instance: Dependency = containerForInstanceStoring?.instanceStore
            .getInstance(with: registrationInfo.name) {
            return instance
        }

        switch containerForInstanceStoring {
        case .some(let container):
            let childResolver = Resolver(resolvingContainer: container, stack: newStack)
            return try registration.createAndSave(resolver: childResolver, store: container.instanceStore)

        case .none:
            let childResolver = Resolver(resolvingContainer: resolvingContainer, stack: newStack)
            return try registration.create(resolver: childResolver)
        }
}

private func hierarchyDoesNotContainCircularDependencies(stack: ResolvingStack, currentStackItem: ResolvingStackItem) -> Bool {
    for item in stack.stack {
        if item.dependencyKey == currentStackItem.dependencyKey
            && item.registrationOwnerContainer === currentStackItem.registrationOwnerContainer {
            return false
        }
    }
    
    return true
}
