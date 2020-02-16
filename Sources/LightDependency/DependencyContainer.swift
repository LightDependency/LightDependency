import Foundation

public final class DependencyContainer {

    static let resolvingContainerName = "RESOLVING_CONTAINER_NAME"

    public let name: String?
    public let id: String
    let parent: DependencyContainer?
    let instanceStorage = InstanceStorage()
    let registrationStorage: ContainerRegistrationStorage
    let scopes: Set<String>

    private init(
        id: String,
        parent: DependencyContainer?,
        name: String?,
        scopes: Set<String>,
        defaults: RegistrationDefaults,
        performRegistration: (ConfigurationContext) -> Void
    ) {
        self.parent = parent
        self.name = name
        self.scopes = scopes
        self.id = id

        let context = ConfigurationContext(defaults: defaults)
        performRegistration(context)
        let registrationStorageBuilder = ContainerRegistrationStorageBuilder()

        if parent == nil {
            DependencyContainer.getCommonDependencies().apply(to: registrationStorageBuilder)
        }

        context.apply(to: registrationStorageBuilder)
        registrationStorage = registrationStorageBuilder.registrationStorage
    }

    public convenience init(
        defaults: RegistrationDefaults = .default,
        file: StaticString = #file,
        line: UInt = #line,
        performRegistration: (ConfigurationContext) -> Void
    ) {
        let id = generateID(resolutionDescription: "\(file):\(line)")
        self.init(id: id, parent: nil, name: "root", scopes: [], defaults: defaults, performRegistration: performRegistration)
    }

    public func resolve<Dependency>(_ useResolver: (Resolver) throws -> Dependency) rethrows -> Dependency {
        let resolver = Resolver(resolvingContainer: self)
        defer { resolver.dispose() }
        return try useResolver(resolver)
    }

    var nameAndID: String {
        return "\(name ?? "noname") (id: \(id))"
    }
}

extension DependencyContainer {
    public func resolve<Dependency>(file: StaticString = #file, line: UInt = #line) throws -> Dependency {
        return try resolve { resolver in try resolver.resolve(file: file, line: line) }
    }
}

extension DependencyContainer {
    public func createChildContainer(
        name: String? = nil,
        scopes: Set<String> = [],
        file: StaticString = #file,
        line: UInt = #line,
        performRegistration: (ConfigurationContext) -> Void = { _ in }
    ) -> DependencyContainer {
        let id = generateID(resolutionDescription: "\(file):\(line)")
        return DependencyContainer(id: id, parent: self, name: name, scopes: scopes, defaults: .default, performRegistration: performRegistration)
    }
}

extension DependencyContainer {
    var hierarchy: UnfoldSequence<DependencyContainer, (DependencyContainer?, Bool)> {
        return sequence(first: self, next: { $0.parent })
    }
}

extension DependencyContainer {
    private static func getCommonDependencies() -> ConfigurationContext {
        let context = ConfigurationContext(defaults: .createNewInstancePerResolve)

        context.registerWithResolver { resolver -> DependencyContainer in
            let internalResolver = resolver as! Resolver
            let resolvingContainer = internalResolver.resolvingContainer
            return resolvingContainer
        }
        .asDependency(ofType: { $0 as DependencyContainer })
        .withName(DependencyContainer.resolvingContainerName)

        return context
    }
}

private func generateID(resolutionDescription: String) -> String {
    let id = UUID().uuidString + " (\(resolutionDescription))"
    return id
}
