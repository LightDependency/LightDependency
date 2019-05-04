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

    func create(resolver: Resolver) throws -> Dependency {
        return try transform(original.create(resolver: resolver))
    }

    func createAndSave(resolver: Resolver, store: InstanceStore) throws -> Dependency {
        return try transform(original.createAndSave(resolver: resolver, store: store))
    }

    var primaryDependency: DependencyKey? {
        return DependencyKey(OriginalDependency.self, original.name)
    }
}
