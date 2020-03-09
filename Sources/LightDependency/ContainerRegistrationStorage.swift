import Foundation

final class ContainerRegistrationStorage {

    private let registrations: [ObjectIdentifier: [NameKey: [AnyRegistration]]]

    init(registrations: [ObjectIdentifier: [NameKey: [AnyRegistration]]]) {
        self.registrations = registrations
    }

    func getRegistrations(for key: DependencyKey) -> [AnyRegistration] {
        let typeID = ObjectIdentifier(key.type)
        let nameKey = NameKey(name: key.name)
        return registrations[typeID, default: [:]][nameKey, default: []]
    }

    func getAllRegistrations(for type: Any.Type) -> [(String?, AnyRegistration)] {
        let registrationsForDependency = registrations[ObjectIdentifier(type), default: [:]]

        return registrationsForDependency.flatMap { key, values in
            values.map { value in (key.name, value) }
        }
    }

    func getAllRegistrations() -> [AnyRegistration] {
        registrations.values.flatMap { $0.values.flatMap { $0 } }
    }
}

extension ContainerRegistrationStorage {
    struct NameKey: Hashable {
        let name: String?
    }
}

final class ContainerRegistrationStorageBuilder: RegistrationStorage {
    private var registrations: [ObjectIdentifier: [ContainerRegistrationStorage.NameKey: [AnyRegistration]]] = [:]

    func add<Instance, Dependency>(_ registration: Registration<Instance, Dependency>) {
        let dependencyRegistration = AnyRegistration(registration)
        add(dependencyRegistration)

        let optionalDependencyRegistration = AnyRegistration(registration) { $0 as Dependency? }
        add(optionalDependencyRegistration)
    }

    var registrationStorage: ContainerRegistrationStorage {
        ContainerRegistrationStorage(registrations: registrations)
    }

    private func add(_ registration: AnyRegistration) {
        let typeID = ObjectIdentifier(registration.dependencyKey.type)
        let nameKey = ContainerRegistrationStorage.NameKey(name: registration.dependencyKey.name)
        registrations[typeID, default: [:]][nameKey, default: []].append(registration)
    }
}
