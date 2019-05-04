struct RegistrationInfo<Dependency> {
    let registration: AnyDependencyRegistration<Dependency>
    let name: String?
    let owner: LightContainer
}

struct DebugRegistrationInfo<Dependency> {
    let registration: AnyDependencyRegistration<Dependency>
    let name: String?
    let owner: LightContainer
    let stackItem: ResolvingStackItem
}

extension DebugRegistrationInfo {
    init(registrationInfo: RegistrationInfo<Dependency>, stackItem: ResolvingStackItem) {
        registration = registrationInfo.registration
        name = registrationInfo.name
        owner = registrationInfo.owner
        self.stackItem = stackItem
    }
}

extension RegistrationInfo {
    var key: DependencyKey {
        return DependencyKey(Dependency.self, name)
    }
}
