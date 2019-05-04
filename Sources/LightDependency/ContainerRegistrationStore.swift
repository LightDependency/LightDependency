import Foundation

protocol RegistrationStore: class {
    func add<Dependency>(_ registration: AnyDependencyRegistration<Dependency>, withName name: String?)
    
    func getRegistrations<Dependency>(withName name: String?) -> [AnyDependencyRegistration<Dependency>]
    
    func getAllRegistrations<Dependency>(for type: Dependency.Type) -> [(String?, AnyDependencyRegistration<Dependency>)]
    
    func getAllRegistrations() -> [DependencyRegistrationType]
}

final class ContainerRegistrationStore: RegistrationStore {
    private var noNameRegistrations: [TypeHash: [DependencyRegistrationType]] = [:]
    private var namedRegistrations: [TypeHash: [String: DependencyRegistrationType]] = [:]

    private var noNameRegistrationsLock = pthread_rwlock_t()
    private var namedRegistrationsLock = pthread_rwlock_t()

    init() {
        pthread_rwlock_init(&noNameRegistrationsLock, nil)
        pthread_rwlock_init(&namedRegistrationsLock, nil)
    }
    
    func add<Dependency>(_ registration: AnyDependencyRegistration<Dependency>, withName name: String?) {
        let typeHash = TypeHash(Dependency.self)
        
        switch name {
        case .none:
            pthread_rwlock_wrlock(&noNameRegistrationsLock)
            defer { pthread_rwlock_unlock(&noNameRegistrationsLock) }
            noNameRegistrations[typeHash, default: []].append(registration)

        case .some(let name):
            pthread_rwlock_wrlock(&namedRegistrationsLock)
            defer { pthread_rwlock_unlock(&namedRegistrationsLock) }
            namedRegistrations[typeHash, default: [:]][name] = registration
        }
    }
    
    func getRegistrations<Dependency>(withName name: String?) -> [AnyDependencyRegistration<Dependency>] {
        let typeHash = TypeHash(Dependency.self)
        
        switch name {
        case .some(let name):
            pthread_rwlock_rdlock(&namedRegistrationsLock)
            defer { pthread_rwlock_unlock(&namedRegistrationsLock) }
            guard let registration = namedRegistrations[typeHash]?[name] as? AnyDependencyRegistration<Dependency>
                else { return [] }

            return [registration]

        case .none:
            pthread_rwlock_rdlock(&noNameRegistrationsLock)
            defer { pthread_rwlock_unlock(&noNameRegistrationsLock) }

            guard let registrations = noNameRegistrations[typeHash] as? [AnyDependencyRegistration<Dependency>]
                else { return [] }

            return registrations
        }
    }
    
    func getAllRegistrations<Dependency>(for type: Dependency.Type) -> [(String?, AnyDependencyRegistration<Dependency>)] {
        let typeHash = TypeHash(Dependency.self)
        
        var result: [(String?, AnyDependencyRegistration<Dependency>)] = []

        pthread_rwlock_rdlock(&noNameRegistrationsLock)

        if let noNamedRegistrations = noNameRegistrations[typeHash] as? [AnyDependencyRegistration<Dependency>] {
            result.append(contentsOf: noNamedRegistrations.map { (nil, $0 )})
        }

        pthread_rwlock_unlock(&noNameRegistrationsLock)

        pthread_rwlock_rdlock(&namedRegistrationsLock)
        
        if let namedRegistrations = self.namedRegistrations[typeHash] as? [String: AnyDependencyRegistration<Dependency>] {
            result.append(contentsOf: namedRegistrations.map { $0 })
        }

        pthread_rwlock_unlock(&namedRegistrationsLock)
        
        return result
    }
    
    func getAllRegistrations() -> [DependencyRegistrationType] {
        pthread_rwlock_rdlock(&noNameRegistrationsLock)

        let noNameRegistrations = self.noNameRegistrations
            .flatMap { $0.value }

        pthread_rwlock_unlock(&noNameRegistrationsLock)

        pthread_rwlock_rdlock(&namedRegistrationsLock)

        let namedRegistrations = self.namedRegistrations
            .flatMap { $0.value.map { $0.value } }

        pthread_rwlock_unlock(&namedRegistrationsLock)

        return noNameRegistrations + namedRegistrations
    }
}
