public final class ConfiguarationContext: RegistrationContext {
    let defaults: RegistrationDefaults
    private var registrationActions: [(RegistrationContext) -> Void] = []

    public init(defaults: RegistrationDefaults) {
        self.defaults = defaults
    }

    public func add<Instance, Dependency>(_ registration: Registration<Instance, Dependency>, debugInfo: DebugInfo) {
        let action = { (context: RegistrationContext) in
            context.add(registration, debugInfo: debugInfo)
        }

        registrationActions.append(action)
    }

    @discardableResult
    public func register<Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping (Resolver) throws -> Instance)
        -> RegistrationConfig<Instance> {
            let config = RegistrationConfig(
                factory: factory,
                defaults: defaults,
                debugInfo: DebugInfo(file: file, line: line))

            registrationActions.append(config.addToContext(_:))
            return config
    }

    @discardableResult
    public func register<Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping () throws -> Instance)
        -> RegistrationConfig<Instance> {
            let config = RegistrationConfig(
                factory: { _ in try factory() },
                defaults: defaults,
                debugInfo: DebugInfo(file: file, line: line))
            
            registrationActions.append(config.addToContext(_:))
            return config
    }

    public func apply(to containerContext: RegistrationContext) {
        for action in registrationActions {
            action(containerContext)
        }
    }
}

extension Container {
    public func configure(defaults: RegistrationDefaults, _ performRegistrations: (ConfiguarationContext) -> Void) {
        addRegistrations { containerContext in
            let context = ConfiguarationContext(defaults: defaults)
            performRegistrations(context)
            context.apply(to: containerContext)
        }
    }
}

extension RegistrationContext {
    public func with(defaults: RegistrationDefaults, _ performRegistrations: (ConfiguarationContext) -> Void) {
        let context = ConfiguarationContext(defaults: defaults)
        performRegistrations(context)
        context.apply(to: self)
    }
}

extension ConfiguarationContext {
    @discardableResult
    public func registerInstance<Instance>(_ instance: Instance) -> RegistrationConfig<Instance> {
        return register(constant(instance)).perResolve()
    }
}
