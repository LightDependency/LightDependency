public final class DependencyResolutionError: Error {
    public enum ErrorType {
        case dependencyNotRegistered
        case resolvingIsForbiddenBecauseRequiresSavingInstanceWithDependencyFromChildContainer
        case recursiveDependencyFound
        case usingScopedContainerForRegistrationFromChildContainer
        case scopeWasNotFoundUpToHierarchy
        case tryingToResolveSingleDependencyWhenMultipleAreRegistered
    }

    public let errorType: ErrorType
    public let dependencyType: Any.Type
    public let dependencyName: String?
    public let resolvingStack: ResolvingStack
    public let additionalInfo: String?
    public let file: StaticString
    public let line: UInt

    init(errorType: ErrorType,
         dependencyType: Any.Type,
         dependencyName: String?,
         resolvingStack: ResolvingStack,
         additionalInfo: String? = nil,
         file: StaticString,
         line: UInt) {
        self.errorType = errorType
        self.dependencyType = dependencyType
        self.dependencyName = dependencyName
        self.resolvingStack = resolvingStack
        self.additionalInfo = additionalInfo
        self.file = file
        self.line = line
    }
}

extension DependencyResolutionError: CustomStringConvertible {
    public var description: String {
        return formatError()
    }

    private var dependencyKeyDescription: String {
        switch dependencyName {
        case .some(let name): return "\(dependencyType) with name: \"\(name)\""
        case .none: return "\(dependencyType) without name"
        }
    }

    private var errorTypeDescription: String {
        switch errorType {
        case .dependencyNotRegistered:
            return "Type is not registered"

        case .resolvingIsForbiddenBecauseRequiresSavingInstanceWithDependencyFromChildContainer:
            return "Resolving is forbidden because requires saving instance with dependency from child container"

        case .recursiveDependencyFound:
            return "Recursive dependency found"

        case .usingScopedContainerForRegistrationFromChildContainer:
            return "Storing instance in scoped container that is ancestor for registration owner container is forbidden"

        case .scopeWasNotFoundUpToHierarchy:
            return "Scope was not found up to hierarchy"

        case .tryingToResolveSingleDependencyWhenMultipleAreRegistered:
            return "trying to resolve single dependency when multiple instances registered for that dependency type"
        }
    }

    private var stackLines: [String] {
        var lines = resolvingStack.lines
        guard !lines.isEmpty else { return [] }
        lines.insert("Stack:", at: 0)
        return lines
    }

    private var additionalInfoLines: [String] {
        guard let additionalInfo = self.additionalInfo else { return [] }
        return [additionalInfo]
    }

    private func getInitialResolutionPlace() -> (file: StaticString, line: UInt) {
        if let resolutionPlace = resolvingStack.stack.first?.resolutionPlace {
            return (resolutionPlace.file, resolutionPlace.line)
        }

        return (file, line)
    }

    private func formatError() -> String {
        let firstLine = "DependencyResolutionError: " + errorTypeDescription
        let dependencyKeyLine = "Dependency type – " + dependencyKeyDescription
        let (file, line) = getInitialResolutionPlace()
        let placeLine = "place: \(file):\(line)"

        let allLines = [[firstLine, dependencyKeyLine, placeLine], stackLines, additionalInfoLines].flatMap { $0 }
        return allLines.joined(separator: "\n  ")
    }
}
