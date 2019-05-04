protocol DependencyRegistrationType {
    var key: DependencyKey { get }
    var lifestyle: InstanceLifestyle { get }
    var debugInfo: DebugInfo { get }
    var primaryDependency: DependencyKey? { get }
}

protocol DependencyFactoryType {
    associatedtype Dependency

    func create(resolver: Resolver) throws -> Dependency
    func createAndSave(resolver: Resolver, store: InstanceStore) throws -> Dependency
}
