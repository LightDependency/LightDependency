public final class RegistrationConfig<Instance> {
    private typealias AddRegistrationAction = (RegistrationHelper<Instance>) -> Void

    private let factory: (Resolver) throws -> Instance
    private var name: String?
    private var lifestyle: InstanceLifestyle?
    private let defaultLifestyle: InstanceLifestyle
    private var addRegisterationActions: [AddRegistrationAction] = []
    private var setUpActions: [SetUpAction<Instance>] = []
    private let debugInfo: DebugInfo
    private let initializerDependencies: [KnownDependency]?

    init(factory: @escaping (Resolver) throws -> Instance,
         initializerDependencies: [KnownDependency]?,
         defaultLifestyle: InstanceLifestyle,
         debugInfo: DebugInfo
    ) {
        self.factory = factory
        self.initializerDependencies = initializerDependencies
        self.defaultLifestyle = defaultLifestyle
        self.debugInfo = debugInfo
    }

    @discardableResult
    public func withName(_ name: String) -> Self {
        self.name = name
        return self
    }

    @discardableResult
    public func withLifestyle(_ lifestyle: InstanceLifestyle) -> Self {
        self.lifestyle = lifestyle
        return self
    }

    @discardableResult
    public func asDependency<Dependency>(
        file: StaticString = #file,
        line: UInt = #line,
        ofType casting: @escaping (Instance) -> Dependency
    ) -> Self {

        addRegisterationActions.append({ helper in
            helper.add(casting: casting, debugInfo: DebugInfo(file: file, line: line))
        })

        return self
    }

    @discardableResult
    public func asNamedDependency<Dependency>(
        _ name: String,
        file: StaticString = #file,
        line: UInt = #line,
        ofType casting: @escaping (Instance) -> Dependency
    ) -> Self {

        addRegisterationActions.append({ helper in
            helper.add(name: name, casting: casting, debugInfo: DebugInfo(file: file, line: line))
        })

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

    @discardableResult
    public func setUp(
        file: StaticString = #file,
        line: UInt = #line,
        _ setUp: @escaping (Instance) throws -> Void
    ) -> Self {

        let setUpAction = SetUpAction(
            action: { instance, _ in try setUp(instance) },
            debugInfo: DebugInfo(file: file, line: line)
        )

        setUpActions.append(setUpAction)
        return self
    }

    func addToContext(_ storage: RegistrationStorage) {
        let helper = RegistrationHelper(
            storage: storage,
            factory: factory,
            defaultName: name,
            lifestyle: lifestyle ?? defaultLifestyle,
            initializerDependencies: initializerDependencies,
            setUpActions: setUpActions,
            lock: RegistrationLock()
        )

        guard !addRegisterationActions.isEmpty else {
            helper.add(casting: { $0 }, debugInfo: debugInfo)
            return
        }

        for action in addRegisterationActions {
            action(helper)
        }
    }
}

extension RegistrationConfig {
    @discardableResult @inlinable
    public func asTransient() -> RegistrationConfig {
        withLifestyle(.transient)
    }

    @discardableResult @inlinable
    public func asSingleton() -> RegistrationConfig {
        withLifestyle(.singleton)
    }

    @discardableResult @inlinable
    public func perContainer() -> RegistrationConfig {
        withLifestyle(.container)
    }

    @discardableResult @inlinable
    public func asScoped(_ name: String) -> RegistrationConfig {
        withLifestyle(.scoped(name))
    }
}
