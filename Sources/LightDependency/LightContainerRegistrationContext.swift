final class LightContainerRegistrationContext: RegistrationContext {
    private var registrationActions: [(LightContainer) -> Void] = []

    func add<Instance, Dependency>(_ registration: Registration<Instance, Dependency>, debugInfo: DebugInfo) {
        let dependencyRegistration = SynchronizedDependencyRegistration(
            registration: registration, debugInfo: debugInfo, name: registration.name)
        
        let dependencyRegistrationForOptional = TransformedDependencyRegistration(
            original: dependencyRegistration,
            transform: { $0 as Optional<Dependency> })

        let registrationAction = { (container: LightContainer) in
            container.addDependency(AnyDependencyRegistration(dependencyRegistration), name: registration.name)
            container.addDependency(AnyDependencyRegistration(dependencyRegistrationForOptional), name: registration.name)
        }

        registrationActions.append(registrationAction)
    }

    func apply(to container: LightContainer) {
        for action in registrationActions {
            action(container)
        }
    }
}
