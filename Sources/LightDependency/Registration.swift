import Foundation

struct SetUpAction<Instance> {
    private let action: (Instance, Resolver) throws -> Void
    let debugInfo: DebugInfo

    init(action: @escaping (Instance, Resolver) throws -> Void, debugInfo: DebugInfo) {
        self.action = action
        self.debugInfo = debugInfo
    }

    func carryingInstance(_ instance: Instance) -> ClosureSetUpAction {
        ClosureSetUpAction(debugInfo: debugInfo) { [action] resolver in
            try action(instance, resolver)
        }
    }
}

struct ClosureSetUpAction {
    let debugInfo: DebugInfo
    let setUp: (Resolver) throws -> Void

    init(debugInfo: DebugInfo, setUp: @escaping (Resolver) throws -> Void) {
        self.debugInfo = debugInfo
        self.setUp = setUp
    }
}

final class Registration<Instance, Dependency> {
    let name: String?
    let lifestyle: InstanceLifestyle
    let factory: (Resolver) throws -> Instance
    let setUpActions: [SetUpAction<Instance>]
    let casting: (Instance) -> Dependency
    let lock: RegistrationLock
    let debugInfo: DebugInfo

    init(name: String?,
         lifestyle: InstanceLifestyle,
         factory: @escaping (Resolver) throws -> Instance,
         setUpActions: [SetUpAction<Instance>],
         casting: @escaping (Instance) -> Dependency,
         lock: RegistrationLock = .init(),
         debugInfo: DebugInfo
    ) {
        self.name = name
        self.lifestyle = lifestyle
        self.factory = factory
        self.setUpActions = setUpActions
        self.casting = casting
        self.lock = lock
        self.debugInfo = debugInfo
    }
}

struct CreateDependencyResult<Dependency> {
    let dependency: Dependency
    let setUpActions: [ClosureSetUpAction]
}

extension Registration {
    fileprivate func createDependency(resolver: Resolver) throws -> CreateDependencyResult<Dependency> {
        let instance = try factory(resolver)
        let dependency = casting(instance)

        let setUpActions = self.setUpActions.map { action in action.carryingInstance(instance) }

        return CreateDependencyResult(dependency: dependency, setUpActions: setUpActions)
    }

    fileprivate func createAndSaveDependency(resolver: Resolver, storage: InstanceStorage) throws
        -> CreateDependencyResult<Dependency>
    {
        lock.lock()

        if let existingInstance: Instance = storage.getInstance(with: name) {
            lock.unlock()
            let dependency = casting(existingInstance)
            return CreateDependencyResult(dependency: dependency, setUpActions: [])
        }

        let instance: Instance = try _do({
            let instance = try factory(resolver)
            storage.save(instance: instance, name: name)
            return instance
        }, finally: lock.unlock)

        let dependency = casting(instance)

        let setUpActions = self.setUpActions.map { action in action.carryingInstance(instance) }

        return CreateDependencyResult(dependency: dependency, setUpActions: setUpActions)
    }

    fileprivate func getFromStorage(storage: InstanceStorage) -> Dependency? {
        storage.getInstance(with: name)
    }
}

struct DependencyFactory<Dependency> {
    typealias CreateDependency = (Resolver) throws -> CreateDependencyResult<Dependency>
    typealias CreateAndSaveDependency = (Resolver, InstanceStorage) throws -> CreateDependencyResult<Dependency>
    typealias GetFromStorage = (InstanceStorage) -> Dependency?

    let create: CreateDependency
    let createAndSave: CreateAndSaveDependency
    let getFromStorage: GetFromStorage
}

extension DependencyFactory {
    fileprivate func map<Transformed>(_ transform: @escaping (Dependency) -> Transformed) -> DependencyFactory<Transformed> {
        DependencyFactory<Transformed>(
            create: { [create] resolver in
                let result = try create(resolver)

                return CreateDependencyResult(
                    dependency: transform(result.dependency),
                    setUpActions: result.setUpActions
                )
            },
            createAndSave: { [createAndSave] resolver, storage in
                let result = try createAndSave(resolver, storage)

                return CreateDependencyResult(
                    dependency: transform(result.dependency),
                    setUpActions: result.setUpActions
                )
            },
            getFromStorage: { [getFromStorage] storage in
                getFromStorage(storage).map(transform)
            }
        )
    }
}

extension DependencyFactory {
    @inline(__always)
    func createAndSaveIfNeeded(resolver: Resolver, storage: InstanceStorage?) throws -> CreateDependencyResult<Dependency> {
        if let storage = storage {
            return try createAndSave(resolver, storage)
        } else {
            return try create(resolver)
        }
    }
}

final class AnyRegistration {
    let dependencyKey: DependencyKey
    let lifestyle: InstanceLifestyle
    let primaryDependency: DependencyKey?
    let debugInfo: DebugInfo
    let factory: Any

    init<Instance, Dependency>(_ registration: Registration<Instance, Dependency>) {
        dependencyKey = DependencyKey(Dependency.self, registration.name)
        lifestyle = registration.lifestyle
        primaryDependency = nil
        debugInfo = registration.debugInfo
        factory = DependencyFactory(
            create: registration.createDependency(resolver:),
            createAndSave: registration.createAndSaveDependency(resolver:storage:),
            getFromStorage: registration.getFromStorage(storage:)
        )
    }

    init<Instance, Dependency, TransformedDependency>(
        _ registration: Registration<Instance, Dependency>,
        _ transform: @escaping (Dependency) -> TransformedDependency
    ) {
        dependencyKey = DependencyKey(TransformedDependency.self, registration.name)
        lifestyle = registration.lifestyle
        primaryDependency = DependencyKey(Dependency.self, registration.name)
        debugInfo = registration.debugInfo
        
        let factory = DependencyFactory(
            create: registration.createDependency(resolver:),
            createAndSave: registration.createAndSaveDependency(resolver:storage:),
            getFromStorage: registration.getFromStorage(storage:)
        )

        self.factory = factory.map(transform)
    }
}
