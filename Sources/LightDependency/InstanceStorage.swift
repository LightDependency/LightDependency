import Foundation

final class InstanceStorage {

    private var instances: [DependencyKey: Any] = [:]
    private let lock = ReadWriteLock()

    func getInstance<T>(with name: String?) -> T? {
        lock.withReaderLock {
            instances[DependencyKey(T.self, name)] as? T
        }
    }
    
    func save<T>(instance: T, name: String?) {
        lock.withWriterLock {
            instances[DependencyKey(T.self, name)] = instance
        }
    }
}
