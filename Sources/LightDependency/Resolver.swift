public final class Resolver: ResolverType {
    private var disposed = false
    let resolvingContainer: DependencyContainer
    private let queue: ResolutionQueue

    init(resolvingContainer: DependencyContainer) {
        self.resolvingContainer = resolvingContainer
        queue = ExecutionQueue()
    }

    init(resolvingContainer: DependencyContainer, executionQueue: ResolutionQueue) {
        self.resolvingContainer = resolvingContainer
        self.queue = executionQueue
    }

    public func resolve<Dependency>(file: StaticString, line: UInt) throws -> Dependency {
        guard !disposed else { resolverIsDisposedFatalError() }
        return try resolve(name: nil, file: file, line: line)
    }

    public func resolve<Dependency>(byName name: String, file: StaticString, line: UInt) throws -> Dependency {
        guard !disposed else { resolverIsDisposedFatalError() }
        return try resolve(name: name, file: file, line: line)
    }

    public func resolveAll<Dependency>(
        from target: ResolveMultipleInstancesSearchTarget,
        file: StaticString,
        line: UInt
    ) throws -> [Dependency] {
        guard !disposed else { resolverIsDisposedFatalError() }

        let registrations = findAllRegistrations(for: Dependency.self, in: resolvingContainer, target: target)
        let filteredRegistrations = filterOverriddenDependencies(registrations, target: target)

        var results: [Dependency] = []

        for registrationInfo in filteredRegistrations {
            let dependency: Dependency = try resolve(registrationInfo, file, line)
            results.append(dependency)
        }

        return results
    }

    public func resolveNamed<Dependency>(
        from target: ResolveMultipleInstancesSearchTarget,
        file: StaticString,
        line: UInt
    ) throws -> [String: Dependency] {
        guard !disposed else { resolverIsDisposedFatalError() }

        let registrations = findAllRegistrations(for: Dependency.self, in: resolvingContainer, target: target)
        let filteredRegistrations = filterOverriddenDependencies(registrations, target: target)

        var dict: [String: Dependency] = [:]

        for registrationInfo in filteredRegistrations {
            guard let name = registrationInfo.registration.dependencyKey.name else { continue }
            let dependency: Dependency = try resolve(registrationInfo, file, line)
            dict[name] = dependency
        }

        return dict
    }

    func dispose() {
        disposed = true
    }

    deinit {
        assert(disposed)
    }

    private func resolve<Dependency>(name: String?, file: StaticString, line: UInt) throws -> Dependency {
        let key = DependencyKey(Dependency.self, name)
        let registrations = findDependencyRegistrations(for: key, in: resolvingContainer)

        guard registrations.count == 1 else {
            if registrations.count == 0 {
                throw errorWhenRegistrationsNotFound(key: key, file: file, line: line)
            } else {
                throw errorWhenMultipleRegistrationsFound(registrations, key: key, file: file, line: line)
            }
        }

        let registrationInfo = registrations[0]
        return try resolve(registrationInfo, file, line)
    }

    private func filterOverriddenDependencies(
        _ registrations: [RegistrationInfo],
        target: ResolveMultipleInstancesSearchTarget)
        -> [RegistrationInfo] {

            guard target == .containerHierarchy else { return registrations }

            var noNamedRegistrations: [RegistrationInfo] = []
            var namedRegistrations: [String: RegistrationInfo] = [:]

            for registrationInfo in registrations.reversed() {
                switch registrationInfo.registration.dependencyKey.name {
                case let .some(name): namedRegistrations[name] = registrationInfo
                case .none: noNamedRegistrations.append(registrationInfo)
                }
            }

            return noNamedRegistrations + Array(namedRegistrations.values)
    }

    private func resolverIsDisposedFatalError() -> Never {
        fatalError("Resolver can be used only in Container.resolve(_:) method.")
    }

    private func getResolvingStack() -> ResolvingStack {
        ResolvingStack(queueInfo: queue.info)
    }

    private func errorWhenRegistrationsNotFound(
        key: DependencyKey,
        file: StaticString,
        line: UInt
    ) -> DependencyResolutionError {
        let containerThatCanResolveInfo = findContainerThatCanResolve(for: key)

        let errorType: DependencyResolutionError.ErrorType
        let additionalInfo: String

        if let info = containerThatCanResolveInfo {
            errorType = .resolvingIsForbiddenBecauseRequiresSavingInstanceWithDependencyFromChildContainer
            additionalInfo = createHelpInfoForForbiddenResolving(from: info)
        } else {
            errorType = .dependencyNotRegistered
            additionalInfo = getAllowableRegistrations(in: resolvingContainer)
        }

        return DependencyResolutionError(
            errorType: errorType,
            dependencyType: key.type,
            dependencyName: key.name,
            resolvingStack: getResolvingStack(),
            additionalInfo: additionalInfo,
            file: file,
            line: line)
    }

    private func errorWhenMultipleRegistrationsFound(
        _ registrations: [RegistrationInfo],
        key: DependencyKey,
        file: StaticString,
        line: UInt
    ) -> DependencyResolutionError {
        DependencyResolutionError(
            errorType: .tryingToResolveSingleDependencyWhenMultipleAreRegistered,
            dependencyType: key.type,
            dependencyName: key.name,
            resolvingStack: getResolvingStack(),
            additionalInfo: createHelpInfoForMultipleRegistrations(registrations),
            file: file,
            line: line)
    }

    private func findContainerThatCanResolve(for key: DependencyKey) -> DebugRegistrationInfo? {
        var currentContainer = resolvingContainer

        let resolvingStack = getResolvingStack()
        for stackItem in resolvingStack.stack {
            guard currentContainer !== stackItem.resolvingContainer else { continue }
            currentContainer = stackItem.resolvingContainer

            let registrations = findDependencyRegistrations(for: key, in: currentContainer)
            switch registrations.count {
            case 0: continue
            case 1: return DebugRegistrationInfo(registrationInfo: registrations[0], stackItem: stackItem)
            default: return nil
            }
        }

        return nil
    }

    private func resolve<Dependency>(
        _ registrationInfo: RegistrationInfo,
        _ file: StaticString,
        _ line: UInt
    ) throws -> Dependency {
        let resolutionPlace = DebugInfo(file: file, line: line)

        let stackItem = ResolvingStackItem(
            dependencyKey: registrationInfo.registration.dependencyKey,
            resolvingContainer: resolvingContainer,
            registrationOwnerContainer: registrationInfo.owner,
            registrationPlace: registrationInfo.registration.debugInfo,
            resolutionPlace: resolutionPlace,
            setUpPlace: nil
        )

        return try queue.sync(item: stackItem) { queue in
            try resolveRecursive(
                registrationInfo: registrationInfo,
                resolvingContainer: resolvingContainer,
                queue: queue,
                resolutionPlace: resolutionPlace
            )
        }
    }
}
