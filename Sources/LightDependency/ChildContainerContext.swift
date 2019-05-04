public final class ChildContainerContext: RegistrationContext {
    private var registrationActions: [(RegistrationContext) -> Void] = []
    public var scopes: Set<String> = []
    public var name: String?
    
    public func add<Instance, Dependency>(_ registration: Registration<Instance, Dependency>, debugInfo: DebugInfo) {
        let action = { (context: RegistrationContext) in
            context.add(registration, debugInfo: debugInfo)
        }

        registrationActions.append(action)
    }

    public init() {
    }

    func apply(to containerContext: RegistrationContext) {
        for action in registrationActions {
            action(containerContext)
        }
    }
}
