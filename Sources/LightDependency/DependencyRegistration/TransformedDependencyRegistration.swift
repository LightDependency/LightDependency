final class TransformedDependencyRegistration<Instance, OriginalDependency, Dependency>: DependencyRegistrationType, DependencyFactoryType {
    private let original: SynchronizedDependencyRegistration<Instance, OriginalDependency>
    private let transform: (OriginalDependency) -> Dependency

    var key: DependencyKey {
        return DependencyKey(Dependency.self, original.name)
    }

    init(original: SynchronizedDependencyRegistration<Instance, OriginalDependency>,
         transform: @escaping (OriginalDependency) -> Dependency) {
        self.original = original
        self.transform = transform
    }

    var lifestyle: InstanceLifestyle {
        return original.lifestyle
    }

    var debugInfo: DebugInfo {
        return original.debugInfo
    }

    func create(resolver: Resolver) throws -> CreateDependencyResult<Dependency> {
        let result = try original.create(resolver: resolver)

        return CreateDependencyResult(
            dependency: transform(result.dependency),
            setUpActions: result.setUpActions
        )
    }

    func createAndSave(resolver: Resolver, storage: InstanceStorage) throws -> CreateDependencyResult<Dependency> {
        let result = try original.createAndSave(resolver: resolver, storage: storage)

        return CreateDependencyResult(
            dependency: transform(result.dependency),
            setUpActions: result.setUpActions
        )
    }

    func getFromStorage(_ storage: InstanceStorage) -> Dependency? {
        let dependency = original.getFromStorage(storage)

        return dependency.map(transform)
    }

    var primaryDependency: DependencyKey? {
        return DependencyKey(OriginalDependency.self, original.name)
    }
}
