public enum InstanceLifestyle {
    case transient
    case container
    case singleton
    case scoped(String)
}

struct SelectContainerContext {
    let resolvingContainer: DependencyContainer
    let registrationOwnerContainer: DependencyContainer
    let queueInfo: ResolutionQueueInfo?
    let dependencyKey: DependencyKey
    let resolutionPlace: DebugInfo
}

extension InstanceLifestyle {
    func selectContainer(_ context: SelectContainerContext) throws -> DependencyContainer? {
        switch self {
        case .transient:
            return nil

        case .container:
            return context.resolvingContainer

        case .singleton:
            return context.registrationOwnerContainer

        case .scoped(let scopeName):
            var storingIsForbidden = false
            var resultContainer: DependencyContainer?

            for container in context.resolvingContainer.hierarchy {
                if container === context.registrationOwnerContainer.parent {
                    storingIsForbidden = true
                }

                if container.scopes.contains(scopeName) {
                    resultContainer = container
                    break
                }
            }

            switch (storingIsForbidden, resultContainer) {
            case (false, .some(let container)):
                return container

            case (true, .some):
                throw DependencyResolutionError(
                    errorType: .usingScopedContainerForRegistrationFromChildContainer,
                    dependencyType: context.dependencyKey.type,
                    dependencyName: context.dependencyKey.name,
                    resolvingStack: ResolvingStack(queueInfo: context.queueInfo),
                    file: context.resolutionPlace.file,
                    line: context.resolutionPlace.line)

            default:
                throw DependencyResolutionError(
                    errorType: .scopeWasNotFoundUpToHierarchy,
                    dependencyType: context.dependencyKey.type,
                    dependencyName: context.dependencyKey.name,
                    resolvingStack: ResolvingStack(queueInfo: context.queueInfo),
                    additionalInfo: "scope name: \(scopeName)",
                    file: context.resolutionPlace.file,
                    line: context.resolutionPlace.line)
            }
        }
    }
}
