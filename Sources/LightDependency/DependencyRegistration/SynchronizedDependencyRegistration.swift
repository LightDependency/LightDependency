final class SynchronizedDependencyRegistration<Instance, Dependency>: DependencyRegistrationType, DependencyFactoryType {
    private let registration: Registration<Instance, Dependency>
    private let lock = RegistrationLock()

    var key: DependencyKey {
        return DependencyKey(Dependency.self, name)
    }

    let debugInfo: DebugInfo
    let name: String?

    init(registration: Registration<Instance, Dependency>, debugInfo: DebugInfo, name: String?) {
        self.registration = registration
        self.debugInfo = debugInfo
        self.name = name
    }

    var lifestyle: InstanceLifestyle {
        return registration.lifestyle
    }

    func create(resolver: Resolver) throws -> Dependency {
        return try registration.casting(registration.factory(resolver))
    }

    func createAndSave(resolver: Resolver, storage: InstanceStorage) throws -> Dependency {
        let lock = registration.lock ?? self.lock

        lock.lock()
        defer { lock.unlock() }

        if let existingInstance: Instance = storage.getInstance(with: registration.name) {
            return registration.casting(existingInstance)
        }

        let instance = try registration.factory(resolver)
        storage.save(instance: instance, name: registration.name)
        return registration.casting(instance)
    }

    var primaryDependency: DependencyKey? {
        return nil
    }
}
