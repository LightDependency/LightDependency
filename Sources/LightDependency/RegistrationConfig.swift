private struct ConfigSettings {
    var name: String?
    var lifestyle: InstanceLifestyle?
}

private struct AddRegistrationActionArgs<Instance> {
    let context: RegistrationStorage
    let config: ConfigSettings
    let defaultLifestyle: InstanceLifestyle
    let lock: RegistrationLock
    let factory: (Resolver) throws -> Instance
    let setUpActions: [SetUpAction<Instance>]
}

public final class RegistrationConfig<Instance> {
    private typealias AddRegistrationAction = (AddRegistrationActionArgs<Instance>) -> Void

    private let factory: (Resolver) throws -> Instance
    private var configSettings: ConfigSettings = ConfigSettings()
    private let defaultLifestyle: InstanceLifestyle
    private var addRegisterationActions: [AddRegistrationAction] = []
    private var setUpActions: [SetUpAction<Instance>] = []
    private let debugInfo: DebugInfo
    private let knownInitDependencies: [KnownDependency]?

    init(factory: @escaping (Resolver) throws -> Instance,
         knownInitDependencies: [KnownDependency]?,
         defaultLifestyle: InstanceLifestyle,
         debugInfo: DebugInfo
    ) {
        self.factory = factory
        self.knownInitDependencies = knownInitDependencies
        self.defaultLifestyle = defaultLifestyle
        self.debugInfo = debugInfo
    }

    @discardableResult
    public func withName(_ name: String) -> Self {
        configSettings.name = name
        return self
    }

    @discardableResult
    public func withLifestyle(_ lifestyle: InstanceLifestyle) -> Self {
        configSettings.lifestyle = lifestyle
        return self
    }

    @discardableResult
    public func asDependency<Dependency>(
        file: StaticString = #file,
        line: UInt = #line,
        ofType casting: @escaping (Instance) -> Dependency
    ) -> Self {
        let addRegistration = { (args: AddRegistrationActionArgs<Instance>) in
            let lifestyle = args.config.lifestyle ?? args.defaultLifestyle

            let registration = Registration<Instance, Dependency>(
                name: args.config.name,
                lifestyle: lifestyle,
                factory: args.factory,
                setUpActions: args.setUpActions,
                casting: casting,
                lock: args.lock,
                debugInfo: DebugInfo(file: file, line: line)
            )

            args.context.add(registration)
        }

        addRegisterationActions.append(addRegistration)

        return self
    }

    @discardableResult
    public func asNamedDependency<Dependency>(
        _ name: String,
        file: StaticString = #file,
        line: UInt = #line,
        ofType casting: @escaping (Instance) -> Dependency
    ) -> Self {

        let addRegistration = { (args: AddRegistrationActionArgs<Instance>) in
            let lifestyle = args.config.lifestyle ?? args.defaultLifestyle

            let registration = Registration<Instance, Dependency>(
                name: name,
                lifestyle: lifestyle,
                factory: args.factory,
                setUpActions: args.setUpActions,
                casting: casting,
                lock: args.lock,
                debugInfo: DebugInfo(file: file, line: line)
            )

            args.context.add(registration)
        }

        addRegisterationActions.append(addRegistration)

        return self
    }

    @discardableResult
    public func setUp(
        file: StaticString = #file,
        line: UInt = #line,
        _ setUp: @escaping (Instance, Resolver) throws -> Void
    ) -> Self {
        let setUpAction = SetUpAction(action: setUp, debugInfo: DebugInfo(file: file, line: line))
        setUpActions.append(setUpAction)
        return self
    }

    func addToContext(_ context: RegistrationStorage) {
        guard !addRegisterationActions.isEmpty else {
            let registration = Registration<Instance, Instance>(
                name: configSettings.name,
                lifestyle: configSettings.lifestyle ?? defaultLifestyle,
                factory: factory,
                setUpActions: setUpActions,
                casting: { $0 },
                debugInfo: debugInfo
            )

            context.add(registration)
            return
        }

        let args = AddRegistrationActionArgs(
            context: context,
            config: configSettings,
            defaultLifestyle: defaultLifestyle,
            lock: RegistrationLock(),
            factory: factory,
            setUpActions: setUpActions
        )

        for action in addRegisterationActions {
            action(args)
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
