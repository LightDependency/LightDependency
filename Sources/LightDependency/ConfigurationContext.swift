protocol RegistrationStorage {
    func add<Instance, Dependency>(_ registration: Registration<Instance, Dependency>, debugInfo: DebugInfo)
}

public final class ConfigurationContext {
    let defaultLifestyle: InstanceLifestyle
    private var registrationActions: [(RegistrationStorage) -> Void] = []

    init(defaultLifestyle: InstanceLifestyle) {
        self.defaultLifestyle = defaultLifestyle
    }

    @discardableResult
    public func registerWithResolver<Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping (ResolverType) throws -> Instance
    ) -> RegistrationConfig<Instance> {

        let config = RegistrationConfig(
            factory: factory,
            defaultLifestyle: defaultLifestyle,
            debugInfo: DebugInfo(file: file, line: line)
        )

        registrationActions.append(config.addToContext(_:))
        return config
    }

    func apply(to registrationStorage: RegistrationStorage) {
        for action in registrationActions {
            action(registrationStorage)
        }
    }
}

extension ConfigurationContext: RegistrationStorage {
    func add<Instance, Dependency>(_ registration: Registration<Instance, Dependency>, debugInfo: DebugInfo) {
        let action = { (storage: RegistrationStorage) in
            storage.add(registration, debugInfo: debugInfo)
        }

        registrationActions.append(action)
    }
}

extension ConfigurationContext {
    public func with(lifestyle: InstanceLifestyle, _ performRegistration: (ConfigurationContext) -> Void) {
        let context = ConfigurationContext(defaultLifestyle: lifestyle)
        performRegistration(context)
        context.apply(to: self)
    }
}

extension ConfigurationContext {
    @discardableResult
    public func registerInstance<Instance>(_ instance: Instance) -> RegistrationConfig<Instance> {
        return register({ _ in instance }).asTransient()
    }
}
