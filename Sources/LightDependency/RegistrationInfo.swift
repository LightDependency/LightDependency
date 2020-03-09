struct RegistrationInfo {
    let registration: AnyRegistration
    let owner: DependencyContainer
}

struct DebugRegistrationInfo {
    let registration: AnyRegistration
    let owner: DependencyContainer
    let stackItem: ResolvingStackItem
}

extension DebugRegistrationInfo {
    init(registrationInfo: RegistrationInfo, stackItem: ResolvingStackItem) {
        registration = registrationInfo.registration
        owner = registrationInfo.owner
        self.stackItem = stackItem
    }
}
