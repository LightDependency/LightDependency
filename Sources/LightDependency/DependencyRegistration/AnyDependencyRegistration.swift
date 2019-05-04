final class AnyDependencyRegistration<Dependency>: DependencyRegistrationType, DependencyFactoryType {
    private let _create: (Resolver) throws -> Dependency
    private let _createAndSave: (Resolver, InstanceStore) throws -> Dependency

    let key: DependencyKey
    let lifestyle: InstanceLifestyle
    let primaryDependency: DependencyKey?
    var debugInfo: DebugInfo

    init<Registration: DependencyRegistrationType & DependencyFactoryType>(_ registration: Registration)
        where Registration.Dependency == Dependency {
            self.key = registration.key
            self.lifestyle = registration.lifestyle
            self.primaryDependency = registration.primaryDependency
            self.debugInfo = registration.debugInfo
            self._create = registration.create
            self._createAndSave = registration.createAndSave
    }

    func create(resolver: Resolver) throws -> Dependency {
        return try _create(resolver)
    }

    func createAndSave(resolver: Resolver, store: InstanceStore) throws -> Dependency {
        return try _createAndSave(resolver, store)
    }
}
