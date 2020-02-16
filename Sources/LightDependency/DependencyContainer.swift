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
        defaultLifestyle: InstanceLifestyle,
        performRegistration: (ConfigurationContext) -> Void
    ) {
        self.parent = parent
        self.name = name
        self.scopes = scopes
        self.id = id

        let context = ConfigurationContext(defaultLifestyle: defaultLifestyle)
        performRegistration(context)
        let registrationStorageBuilder = ContainerRegistrationStorageBuilder()

        if parent == nil {
            DependencyContainer.getCommonDependencies().apply(to: registrationStorageBuilder)
        }

        context.apply(to: registrationStorageBuilder)
        registrationStorage = registrationStorageBuilder.registrationStorage
    }

    public convenience init(
        defaultLifestyle: InstanceLifestyle = .transient,
        file: StaticString = #file,
        line: UInt = #line,
        performRegistration: (ConfigurationContext) -> Void
    ) {
        self.init(
            id: generateID(resolutionDescription: "\(file):\(line)"),
            parent: nil,
            name: "root",
            scopes: [],
            defaultLifestyle: defaultLifestyle,
            performRegistration: performRegistration
        )
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
        DependencyContainer(
            id: generateID(resolutionDescription: "\(file):\(line)"),
            parent: self,
            name: name,
            scopes: scopes,
            defaultLifestyle: .transient,
            performRegistration: performRegistration
        )
    }
}

extension DependencyContainer {
    var hierarchy: UnfoldSequence<DependencyContainer, (DependencyContainer?, Bool)> {
        return sequence(first: self, next: { $0.parent })
    }
}

extension DependencyContainer {
    private static func getCommonDependencies() -> ConfigurationContext {
        let context = ConfigurationContext(defaultLifestyle: .transient)

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
