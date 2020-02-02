import Foundation

public final class DependencyContainer {

    static let resolvingContainerName = "RESOLVING_CONTAINER_NAME"

    public let name: String?
    public let id: String
    let parent: DependencyContainer?
    let instanceStore = ContainerInstanceStore()
    let registrationStore = ContainerRegistrationStore()
    let scopes: Set<String>
    private var lock = os_unfair_lock()

    private init(
        id: String,
        parent: DependencyContainer?,
        name: String? = nil,
        scopes: Set<String> = [],
        performRegistration: (ConfigurationContext) -> Void = { _ in }
    ) {
        self.parent = parent
        self.name = name
        self.scopes = scopes
        self.id = id

        if parent == nil {
            registerCommonDependencies()
        }

        let context = ConfigurationContext(defaults: .default)
        performRegistration(context)
        context.apply(to: self)
    }

    public convenience init(
        name: String? = nil,
        scopes: Set<String> = [],
        file: StaticString = #file,
        line: UInt = #line,
        performRegistration: (ConfigurationContext) -> Void = { _ in }
    ) {
        let id = generateID(resolutionDescription: "\(file):\(line)")
        self.init(id: id, parent: nil, name: name, scopes: scopes, performRegistration: performRegistration)
    }

    public func configure(defaults: RegistrationDefaults, performRegistration: (ConfigurationContext) -> Void) {
        let context = ConfigurationContext(defaults: defaults)
        performRegistration(context)
        os_unfair_lock_lock(&lock)
        context.apply(to: self)
        os_unfair_lock_unlock(&lock)
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
        return DependencyContainer(id: id, parent: self, name: name, scopes: scopes, performRegistration: performRegistration)
    }
}

extension DependencyContainer: RegistrationStorage {
    func add<Instance, Dependency>(_ registration: Registration<Instance, Dependency>, debugInfo: DebugInfo) {
        let dependencyRegistration = SynchronizedDependencyRegistration(
            registration: registration, debugInfo: debugInfo, name: registration.name)

        let dependencyRegistrationForOptional = TransformedDependencyRegistration(
            original: dependencyRegistration,
            transform: { $0 as Optional<Dependency> })

        registrationStore.add(AnyDependencyRegistration(dependencyRegistration), withName: registration.name)
        registrationStore.add(AnyDependencyRegistration(dependencyRegistrationForOptional), withName: registration.name)
    }
}

extension DependencyContainer {
    var hierarchy: UnfoldSequence<DependencyContainer, (DependencyContainer?, Bool)> {
        return sequence(first: self, next: { $0.parent })
    }
}

extension DependencyContainer {
    private func registerCommonDependencies() {
        let context = ConfigurationContext(defaults: .createNewInstancePerResolve)
        defer { context.apply(to: self) }

        context.registerWithResolver { resolver -> DependencyContainer in
            let internalResolver = resolver as! Resolver
            let resolvingContainer = internalResolver.resolvingContainer
            let id = generateID(resolutionDescription: internalResolver.resolvingStack.stack.last?.description ?? "")
            let childContainer = DependencyContainer(id: id, parent: resolvingContainer)
            return childContainer
        }
        .asDependency(ofType: { $0 as DependencyContainer })

        context.registerWithResolver { resolver -> DependencyContainer in
            let internalResolver = resolver as! Resolver
            let resolvingContainer = internalResolver.resolvingContainer
            return resolvingContainer
        }
        .asDependency(ofType: { $0 as DependencyContainer })
        .withName(DependencyContainer.resolvingContainerName)
    }
}

private func generateID(resolutionDescription: String) -> String {
    let id = UUID().uuidString + " (\(resolutionDescription))"
    return id
}
