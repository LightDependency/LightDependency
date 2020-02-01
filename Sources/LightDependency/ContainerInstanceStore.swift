import Foundation

protocol InstanceStore: class {
    func getInstance<T>(with name: String?) -> T?
    func save<T>(instance: T, name: String?)
}

final class ContainerInstanceStore: InstanceStore {
    private struct TypeAndNameKey: Hashable {
        let typeIdentifier: ObjectIdentifier
        let name: String
    }
    
    private var defaultInstances: [ObjectIdentifier: Any] = [:]
    private var namedInstances: [TypeAndNameKey: Any] = [:]

    private var defaultInstancesLock = pthread_rwlock_t()
    private var namedInstancesLock = pthread_rwlock_t()

    init() {
        pthread_rwlock_init(&defaultInstancesLock, nil)
        pthread_rwlock_init(&namedInstancesLock, nil)
    }
    
    func getInstance<T>(with name: String?) -> T? {
        switch name {
        case .some(let name):
            let key = TypeAndNameKey(typeIdentifier: ObjectIdentifier(T.self), name: name)
            pthread_rwlock_rdlock(&namedInstancesLock)
            defer { pthread_rwlock_unlock(&namedInstancesLock) }
            return namedInstances[key] as? T
            
        case .none:
            let key = ObjectIdentifier(T.self)
            pthread_rwlock_rdlock(&defaultInstancesLock)
            defer { pthread_rwlock_unlock(&defaultInstancesLock) }
            return defaultInstances[key] as? T
        }
    }
    
    func save<T>(instance: T, name: String?) {
        switch name {
        case .some(let name):
            let key = TypeAndNameKey(typeIdentifier: ObjectIdentifier(T.self), name: name)
            pthread_rwlock_wrlock(&namedInstancesLock)
            defer { pthread_rwlock_unlock(&namedInstancesLock) }
            namedInstances[key] = instance
            
        case .none:
            let key = ObjectIdentifier(T.self)
            pthread_rwlock_wrlock(&defaultInstancesLock)
            pthread_rwlock_unlock(&defaultInstancesLock)
            defaultInstances[key] = instance
        }
    }
}
