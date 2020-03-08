final class AnyDependencyRegistration<Dependency>: DependencyRegistrationType, DependencyFactoryType {
    private let _create: (Resolver) throws -> CreateDependencyResult<Dependency>
    private let _createAndSave: (Resolver, InstanceStorage) throws -> CreateDependencyResult<Dependency>
    private let _getFromStorage: (InstanceStorage) -> Dependency?

    let key: DependencyKey
    let lifestyle: InstanceLifestyle
    let primaryDependency: DependencyKey?
    let debugInfo: DebugInfo

    init<Registration: DependencyRegistrationType & DependencyFactoryType>(_ registration: Registration)
        where Registration.Dependency == Dependency {
            self.key = registration.key
            self.lifestyle = registration.lifestyle
            self.primaryDependency = registration.primaryDependency
            self.debugInfo = registration.debugInfo
            self._create = registration.create
            self._createAndSave = registration.createAndSave
            self._getFromStorage = registration.getFromStorage
    }

    func create(resolver: Resolver) throws -> CreateDependencyResult<Dependency> {
        return try _create(resolver)
    }

    func createAndSave(resolver: Resolver, storage: InstanceStorage) throws -> CreateDependencyResult<Dependency> {
        return try _createAndSave(resolver, storage)
    }

    func getFromStorage(_ storage: InstanceStorage) -> Dependency? {
        _getFromStorage(storage)
    }
}
