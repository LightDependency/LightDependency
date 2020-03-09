final class RegistrationHelper<Instance> {
    private let factory: (Resolver) throws -> Instance
    private let storage: RegistrationStorage
    private let defaultName: String?
    private let lifestyle: InstanceLifestyle
    private let initializerDependencies: [KnownDependency]?
    private let setUpActions: [SetUpAction<Instance>]
    private let lock: RegistrationLock

    init(storage: RegistrationStorage,
         factory: @escaping (Resolver) throws -> Instance,
         defaultName: String?,
         lifestyle: InstanceLifestyle,
         initializerDependencies: [KnownDependency]?,
         setUpActions: [SetUpAction<Instance>],
         lock: RegistrationLock
    ) {
        self.storage = storage
        self.factory = factory
        self.defaultName = defaultName
        self.lifestyle = lifestyle
        self.initializerDependencies = initializerDependencies
        self.setUpActions = setUpActions
        self.lock = lock
    }

    func add<Dependency>(
        name: String? = nil,
        casting: @escaping (Instance) -> Dependency,
        debugInfo: DebugInfo
    ) {
        let registration = Registration<Instance, Dependency>(
            name: name ?? defaultName,
            lifestyle: lifestyle,
            initializerDependencies: initializerDependencies,
            factory: factory,
            setUpActions: setUpActions,
            casting: casting,
            lock: lock,
            debugInfo: debugInfo
        )

        storage.add(registration)
    }
}
