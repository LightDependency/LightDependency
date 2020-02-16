public enum InstanceLifestyle {
    case transient
    case container
    case singleton
    case scoped(String)
}

struct SelectContainerContext {
    let resolvingContainer: DependencyContainer
    let registrationOwnerContainer: DependencyContainer
    let resolvingStack: ResolvingStack
    let dependencyKey: DependencyKey
    let file: StaticString
    let line: UInt
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
                    resolvingStack: context.resolvingStack,
                    file: context.file,
                    line: context.line)

            default:
                throw DependencyResolutionError(
                    errorType: .scopeWasNotFoundUpToHierarchy,
                    dependencyType: context.dependencyKey.type,
                    dependencyName: context.dependencyKey.name,
                    resolvingStack: context.resolvingStack,
                    additionalInfo: "scope name: \(scopeName)",
                    file: context.file,
                    line: context.line)
            }
        }
    }
}
