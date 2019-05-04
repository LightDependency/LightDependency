public enum InstanceLifestyle {
    case perResolve
    case perContainer
    case singleton
    case namedScope(String)
}

struct SelectContainerContext<Container> {
    let resolvingContainer: Container
    let registrationOwnerContainer: Container
    let resolvingStack: ResolvingStack
    let dependencyKey: DependencyKey
    let file: StaticString
    let line: UInt
}

extension InstanceLifestyle {
    func selectContainer<Container>(_ context: SelectContainerContext<Container>) throws -> Container? where Container : ScopeContainer {
        switch self {
        case .perResolve:
            return nil

        case .perContainer:
            return context.resolvingContainer

        case .singleton:
            return context.registrationOwnerContainer

        case .namedScope(let scopeName):
            var storingIsForbidden = false
            var resultContainer: Container?

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
