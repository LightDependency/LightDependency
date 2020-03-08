protocol DependencyRegistrationType {
    var key: DependencyKey { get }
    var lifestyle: InstanceLifestyle { get }
    var debugInfo: DebugInfo { get }
    var primaryDependency: DependencyKey? { get }
}

struct CreateDependencyResult<Dependency> {
    let dependency: Dependency
    let setUpActions: [ClosureSetUpAction]
}

protocol DependencyFactoryType {
    associatedtype Dependency

    func create(resolver: Resolver) throws -> CreateDependencyResult<Dependency>
    func createAndSave(resolver: Resolver, storage: InstanceStorage) throws -> CreateDependencyResult<Dependency>
    func getFromStorage(_ storage: InstanceStorage) -> Dependency?
}

extension DependencyFactoryType {
    func createAndSaveIfNeeded(resolver: Resolver, storage: InstanceStorage?) throws -> CreateDependencyResult<Dependency> {
        if let storage = storage {
            return try createAndSave(resolver: resolver, storage: storage)
        } else {
            return try create(resolver: resolver)
        }
    }
}
