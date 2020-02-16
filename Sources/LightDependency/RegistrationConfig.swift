private struct ConfigSettings {
    var name: String?
    var lifestyle: InstanceLifestyle?
}

private struct AddRegistrationActionArgs {
    let context: RegistrationStorage
    let config: ConfigSettings
    let lock: RegistrationLock?
}

public final class RegistrationConfig<Instance> {
    private typealias AddRegistrationAction = (AddRegistrationActionArgs) -> ()

    private let factory: (ResolverType) throws -> Instance
    private var configSettings: ConfigSettings = ConfigSettings()
    private let defaultLifestyle: InstanceLifestyle
    private var addRegisterationActions: [AddRegistrationAction] = []
    private let debugInfo: DebugInfo

    init(factory: @escaping (ResolverType) throws -> Instance,
         defaultLifestyle: InstanceLifestyle,
         debugInfo: DebugInfo
    ) {
        self.factory = factory
        self.defaultLifestyle = defaultLifestyle
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
            let addRegistration = { [factory, defaultLifestyle] (args: AddRegistrationActionArgs) in
                let lifestyle = args.config.lifestyle ?? defaultLifestyle

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
            let addRegistration = { [factory, defaultLifestyle] (args: AddRegistrationActionArgs) in
                let lifestyle = args.config.lifestyle ?? defaultLifestyle

                let registration = Registration<Instance, Dependency>(
                    name: name, lifestyle: lifestyle, factory: factory, casting: casting, lock: args.lock)

                args.context.add(registration, debugInfo: DebugInfo(file: file, line: line))
            }

            addRegisterationActions.append(addRegistration)

            return self
    }

    func addToContext(_ context: RegistrationStorage) {
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
                lifestyle: configSettings.lifestyle ?? defaultLifestyle,
                factory: factory)

            context.add(registration, debugInfo: debugInfo)
        }
    }
}

extension RegistrationConfig {
    @discardableResult
    public func asTransient() -> RegistrationConfig {
        return withLifestyle(.transient)
    }
    
    @discardableResult
    public func asSingleton() -> RegistrationConfig {
        return withLifestyle(.singleton)
    }
    
    @discardableResult
    public func perContainer() -> RegistrationConfig {
        return withLifestyle(.container)
    }
    
    @discardableResult
    public func asScoped(_ name: String) -> RegistrationConfig {
        return withLifestyle(.scoped(name))
    }
}
