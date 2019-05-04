public protocol RegistrationContext {
    func add<Instance, Dependency>(_ registration: Registration<Instance, Dependency>, debugInfo: DebugInfo)
}

public protocol Container {
    func addRegistrations(_: (RegistrationContext) throws -> Void) rethrows

    func resolve<Dependency>(_: (Resolver) throws -> Dependency) rethrows -> Dependency
}
