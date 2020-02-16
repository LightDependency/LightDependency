import Foundation

final class ReadWriteLock {
    fileprivate let rwlock: UnsafeMutablePointer<pthread_rwlock_t> = .allocate(capacity: 1)

    public init() {
        pthread_rwlock_init(rwlock, nil)
    }

    deinit {
        pthread_rwlock_destroy(rwlock)
        rwlock.deallocate()
    }

    public func lockRead() {
        pthread_rwlock_rdlock(rwlock)
    }

    public func lockWrite() {
        pthread_rwlock_wrlock(rwlock)
    }

    public func unlock() {
        pthread_rwlock_unlock(rwlock)
    }
}

extension ReadWriteLock {
    @inlinable
    internal func withReaderLock<T>(_ action: () throws -> T) rethrows -> T {
        lockRead()
        defer { unlock() }

        return try action()
    }

    @inlinable
    internal func withWriterLock<T>(_ action: () throws -> T) rethrows -> T {
        lockWrite()
        defer { unlock() }
        return try action()
    }
}
