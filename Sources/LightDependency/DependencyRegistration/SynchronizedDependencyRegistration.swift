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

    func create(resolver: Resolver) throws -> CreateDependencyResult<Dependency> {
        let instance = try registration.factory(resolver)
        let dependency = registration.casting(instance)

        let setUpActions = registration.setUpActions.map { action in action.carryingInstance(instance) }

        return CreateDependencyResult(dependency: dependency, setUpActions: setUpActions)
    }

    func createAndSave(resolver: Resolver, storage: InstanceStorage) throws -> CreateDependencyResult<Dependency> {
        let lock = registration.lock ?? self.lock

        lock.lock()

        if let existingInstance: Instance = storage.getInstance(with: registration.name) {
            lock.unlock()
            let dependency = registration.casting(existingInstance)
            return CreateDependencyResult(dependency: dependency, setUpActions: [])
        }

        let instance: Instance = try _do({
            let instance = try registration.factory(resolver)
            storage.save(instance: instance, name: registration.name)
            return instance
        }, finally: lock.unlock)

        let dependency = registration.casting(instance)

        let setUpActions = registration.setUpActions.map { action in action.carryingInstance(instance) }

        return CreateDependencyResult(dependency: dependency, setUpActions: setUpActions)
    }

    func getFromStorage(_ storage: InstanceStorage) -> Dependency? {
        storage.getInstance(with: name)
    }

    var primaryDependency: DependencyKey? {
        return nil
    }
}
