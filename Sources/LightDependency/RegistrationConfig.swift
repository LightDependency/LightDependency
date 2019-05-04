private struct ConfigSettings {
    var name: String?
    var lifestyle: InstanceLifestyle?
}

private struct AddRegistrationActionArgs {
    let context: RegistrationContext
    let config: ConfigSettings
    let lock: RegistrationLock?
}

public final class RegistrationConfig<Instance> {
    private typealias AddRegistrationAction = (AddRegistrationActionArgs) -> ()

    private let factory: (Resolver) throws -> Instance
    private var configSettings: ConfigSettings = ConfigSettings()
    private let defaults: RegistrationDefaults
    private var addRegisterationActions: [AddRegistrationAction] = []
    private let debugInfo: DebugInfo

    init(factory: @escaping (Resolver) throws -> Instance, defaults: RegistrationDefaults, debugInfo: DebugInfo) {
        self.factory = factory
        self.defaults = defaults
        self.debugInfo = debugInfo
    }

    @discardableResult
    public func withName(_ name: String) -> RegistrationConfig<Instance> {
        configSettings.name = name
        return self
    }

    @discardableResult
    public func withLifestyle(_ lifestyle: InstanceLifestyle) -> RegistrationConfig<Instance> {
        configSettings.lifestyle = lifestyle
        return self
    }

    @discardableResult
    public func asDependency<Dependency>(
        file: StaticString = #file,
        line: UInt = #line,
        ofType casting: @escaping (Instance) -> Dependency)
        -> RegistrationConfig<Instance> {
            let addRegistration = { [factory, defaults] (args: AddRegistrationActionArgs) in
                let lifestyle = args.config.lifestyle ?? defaults.instanceLifestyle

                let registration = Registration<Instance, Dependency>(
                    name: args.config.name, lifestyle: lifestyle, factory: factory, casting: casting, lock: args.lock)

                args.context.add(registration, debugInfo: DebugInfo(file: file, line: line))
            }

            addRegisterationActions.append(addRegistration)

            return self
    }

    @discardableResult
    public func asNamedDependency<Dependency>(
        _ name: String,
        file: StaticString = #file,
        line: UInt = #line,
        ofType casting: @escaping (Instance) -> Dependency)
        -> RegistrationConfig<Instance> {
            let addRegistration = { [factory, defaults] (args: AddRegistrationActionArgs) in
                let lifestyle = args.config.lifestyle ?? defaults.instanceLifestyle

                let registration = Registration<Instance, Dependency>(
                    name: name, lifestyle: lifestyle, factory: factory, casting: casting, lock: args.lock)

                args.context.add(registration, debugInfo: DebugInfo(file: file, line: line))
            }

            addRegisterationActions.append(addRegistration)

            return self
    }

    func addToContext(_ context: RegistrationContext) {
        if addRegisterationActions.count > 0 {
            let lock = { () -> RegistrationLock? in
                guard addRegisterationActions.count > 1 else { return nil }
                return RegistrationLock()
            }()

            let args = AddRegistrationActionArgs(context: context, config: configSettings, lock: lock)

            for action in addRegisterationActions {
                action(args)
            }
        } else {
            let registration = Registration<Instance, Instance>(
                name: configSettings.name,
                lifestyle: configSettings.lifestyle ?? defaults.instanceLifestyle,
                factory: factory)

            context.add(registration, debugInfo: debugInfo)
        }
    }
}

public extension RegistrationConfig {
    @discardableResult
    func perResolve() -> RegistrationConfig {
        return withLifestyle(.perResolve)
    }
    
    @discardableResult
    func asSingleton() -> RegistrationConfig {
        return withLifestyle(.singleton)
    }
    
    @discardableResult
    func perContainer() -> RegistrationConfig {
        return withLifestyle(.perContainer)
    }
    
    @discardableResult
    func perScope(_ name: String) -> RegistrationConfig {
        return withLifestyle(.namedScope(name))
    }
}
