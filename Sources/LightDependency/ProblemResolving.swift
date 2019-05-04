func createHelpInfoForForbiddenResolving<Dependency>(from info: DebugRegistrationInfo<Dependency>) -> String {
    let stackItem = info.stackItem
    let message = "Can't resolve \(stackItem.dependencyKey) because registration requires saving an instance "
        + "but has the dependency contained in the child container  - \(DependencyKey(Dependency.self, info.name)). "
        + "Saving instances, those created using dependencies from child container is not allowed. "
        + "Consider to use \(InstanceLifestyle.self) = \(InstanceLifestyle.perResolve) or \(InstanceLifestyle.perContainer) on registration \(stackItem.dependencyKey)"

    return message
}

func createHelpInfoForMultipleRegistrations<Dependency>(_ registrations: [RegistrationInfo<Dependency>]) -> String {
    let lines = registrations.enumerated().map { (index, info) in
        "  \(index + 1). \(info.registration.debugInfo)"
    }

    return "registrations found: \n" + lines.joined(separator: "\n")
}

func getAllowableRegistrations(in container: LightContainer) -> String {
    var lines = ["Allowable registrations: "]
    for container in container.hierarchy {
        lines.append("  registrations in container: \(container.name)")
        let registrations = container.registrationStore.getAllRegistrations()
        let primaryRegistrations = registrations.filter { $0.primaryDependency == nil }
        let primaryRegistrationsKeys = primaryRegistrations.map { $0.key }
        lines.append(contentsOf: primaryRegistrationsKeys.map { "    " + $0.description })
    }
    
    return lines.joined(separator: "\n")
}
