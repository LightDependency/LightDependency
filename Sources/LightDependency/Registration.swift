import Foundation

public struct Registration<Instance, Dependency> {
    public let name: String?
    public let lifestyle: InstanceLifestyle
    public let factory: (Resolver) throws -> Instance
    public let casting: (Instance) -> Dependency
    public let lock: RegistrationLock?
    
    public init(name: String? = nil,
                lifestyle: InstanceLifestyle,
                factory: @escaping (Resolver) throws -> Instance,
                casting: @escaping (Instance) -> Dependency,
                lock: RegistrationLock? = nil) {
        self.name = name
        self.lifestyle = lifestyle
        self.factory = factory
        self.casting = casting
        self.lock = lock
    }
}

public final class RegistrationLock {
    private var _lock = os_unfair_lock()

    public init() {
    }

    func lock() {
        os_unfair_lock_lock(&_lock)
    }

    func unlock() {
        os_unfair_lock_unlock(&_lock)
    }
}

extension Registration where Instance == Dependency {
    public init(name: String? = nil,
         lifestyle: InstanceLifestyle,
         factory: @escaping (Resolver) throws -> Instance) {
        self.init(name: name, lifestyle: lifestyle, factory: factory, casting: { $0 })
    }
}
