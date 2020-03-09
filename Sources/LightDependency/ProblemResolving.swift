func createHelpInfoForForbiddenResolving(from info: DebugRegistrationInfo) -> String {
    let stackItem = info.stackItem
    let message = "Can't resolve \(stackItem.dependencyKey) because registration requires saving an instance "
        + "but has the dependency contained in the child container  - \(info.registration.dependencyKey). "
        + "Saving instances, those created using dependencies from child container is not allowed. "
        + "Consider to use \(InstanceLifestyle.self) = \(InstanceLifestyle.transient) or \(InstanceLifestyle.container) on registration \(stackItem.dependencyKey)"

    return message
}

func createHelpInfoForMultipleRegistrations(_ registrations: [RegistrationInfo]) -> String {
    let lines = registrations.enumerated().map { (index, info) in
        "  \(index + 1). \(info.registration.debugInfo)"
    }

    return "registrations found: \n" + lines.joined(separator: "\n")
}

func getAllowableRegistrations(in container: DependencyContainer) -> String {
    var lines = ["Allowable registrations: "]
    for container in container.hierarchy {
        lines.append("  registrations in container: \(container.nameAndID)")
        let registrations = container.registrationStorage.getAllRegistrations()
        let primaryRegistrations = registrations.filter { $0.primaryDependency == nil }
        let primaryRegistrationsKeys = primaryRegistrations.map { $0.dependencyKey }
        lines.append(contentsOf: primaryRegistrationsKeys.map { "    " + $0.description })
    }

    return lines.joined(separator: "\n")
}
