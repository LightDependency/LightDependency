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

struct Registration<Instance, Dependency> {
    let name: String?
    let lifestyle: InstanceLifestyle
    let factory: (Resolver) throws -> Instance
    let setUpActions: [SetUpAction<Instance>]
    let casting: (Instance) -> Dependency
    let lock: RegistrationLock?

    init(name: String? = nil,
                lifestyle: InstanceLifestyle,
                factory: @escaping (Resolver) throws -> Instance,
                setUpActions: [SetUpAction<Instance>],
                casting: @escaping (Instance) -> Dependency,
                lock: RegistrationLock? = nil) {
        self.name = name
        self.lifestyle = lifestyle
        self.factory = factory
        self.setUpActions = setUpActions
        self.casting = casting
        self.lock = lock
    }
}

final class RegistrationLock {
    private var _lock = os_unfair_lock()

    init() {
    }

    func lock() {
        os_unfair_lock_lock(&_lock)
    }

    func unlock() {
        os_unfair_lock_unlock(&_lock)
    }
}

extension Registration where Instance == Dependency {
    init(name: String? = nil,
         lifestyle: InstanceLifestyle,
         factory: @escaping (Resolver) throws -> Instance,
         setUpActions: [SetUpAction<Instance>] = []
    ) {
        self.init(name: name, lifestyle: lifestyle, factory: factory, setUpActions: setUpActions, casting: { $0 })
    }
}
