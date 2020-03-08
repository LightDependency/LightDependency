import Foundation

final class ContainerRegistrationStorage {

    private let registrations: [ObjectIdentifier: [NameKey: [DependencyRegistrationType]]]

    init(registrations: [ObjectIdentifier: [NameKey: [DependencyRegistrationType]]]) {
        self.registrations = registrations
    }

    func getRegistrations<Dependency>(withName name: String?) -> [AnyDependencyRegistration<Dependency>] {
        let typeID = ObjectIdentifier(Dependency.self)
        let nameKey = NameKey(name: name)
        return registrations[typeID, default: [:]][nameKey, default: []]
            as! [AnyDependencyRegistration<Dependency>]
    }

    func getAllRegistrations<Dependency>(for type: Dependency.Type) -> [(String?, AnyDependencyRegistration<Dependency>)] {
        let registrationsForDependency = registrations[ObjectIdentifier(type), default: [:]]

        return registrationsForDependency.flatMap { key, values in
            values.map { value in ( key.name, value as! AnyDependencyRegistration<Dependency>) }
        }
    }

    func getAllRegistrations() -> [DependencyRegistrationType] {
        registrations.values.flatMap { $0.values.flatMap { $0 } }
    }
}

extension ContainerRegistrationStorage {
    struct NameKey: Hashable {
        let name: String?
    }
}

final class ContainerRegistrationStorageBuilder: RegistrationStorage {
    private var registrations: [ObjectIdentifier: [ContainerRegistrationStorage.NameKey: [DependencyRegistrationType]]] = [:]

    func add<Instance, Dependency>(_ registration: Registration<Instance, Dependency>, debugInfo: DebugInfo) {
        let dependencyRegistration = SynchronizedDependencyRegistration(
            registration: registration,
            debugInfo: debugInfo,
            name: registration.name
        )

        let dependencyRegistrationForOptional = TransformedDependencyRegistration(
            original: dependencyRegistration,
            transform: { $0 as Dependency? }
        )

        add(dependencyRegistration)
        add(dependencyRegistrationForOptional)
    }

    var registrationStorage: ContainerRegistrationStorage {
        ContainerRegistrationStorage(registrations: registrations)
    }

    private func add<DependencyRegistration>(_ registration: DependencyRegistration)
        where DependencyRegistration: DependencyRegistrationType,
        DependencyRegistration: DependencyFactoryType
    {
        let typeID = ObjectIdentifier(DependencyRegistration.Dependency.self)
        let nameKey = ContainerRegistrationStorage.NameKey(name: registration.key.name)
        let anyDependencyRegistration = AnyDependencyRegistration(registration)

        registrations[typeID, default: [:]][nameKey, default: []].append(anyDependencyRegistration)
    }
}
