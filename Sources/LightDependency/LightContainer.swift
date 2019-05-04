import Foundation

public final class LightContainer: Container {
    let name: String
    let parent: LightContainer?
    let instanceStore: InstanceStore
    let registrationStore: RegistrationStore
    let scopes: Set<String>
    private var lock = os_unfair_lock()
    
    init(parent: LightContainer?, name: String, scopes: Set<String>, registrationContext: LightContainerRegistrationContext? = nil) {
        self.parent = parent
        self.name = name
        instanceStore = ContainerInstanceStore()
        registrationStore = ContainerRegistrationStore()
        self.scopes = scopes

        if let context = registrationContext {
            context.apply(to: self)
        }
    }

    public func addRegistrations(_ performRegistrations: (RegistrationContext) throws -> Void) rethrows {
        let context = LightContainerRegistrationContext()
        try performRegistrations(context)

        os_unfair_lock_lock(&lock)
        context.apply(to: self)
        os_unfair_lock_unlock(&lock)
    }

    public func resolve<Dependency>(_ useResolver: (Resolver) throws -> Dependency) rethrows -> Dependency {
        let resolver = LightResolver(resolvingContainer: self)
        defer { resolver.dispose() }
        return try useResolver(resolver)
    }

    func addDependency<Dependency>(_ dependencyRegistration: AnyDependencyRegistration<Dependency>, name: String?) {
        registrationStore.add(dependencyRegistration, withName: name)
    }
}

extension LightContainer: ScopeContainer { }
