public struct ResolvingStack: CustomStringConvertible {
    public let stack: [ResolvingStackItem]
    
    init() {
        stack = []
    }
    
    private init(stack: [ResolvingStackItem]) {
        self.stack = stack
    }
    
    func adding(_ stackItem: ResolvingStackItem) -> ResolvingStack {
        return ResolvingStack(stack: stack + [stackItem])
    }
    
    public var description: String {
        return lines.joined(separator: "\n")
    }

    var lines: [String] {
        let allFiles = stack
            .flatMap { $0.allFileNames }
            .map(String.init(describing:))

        let commonPath = getCommonPath(for: allFiles)

        var lines: [String] = []
        for (index, item) in stack.enumerated() {
            let line = "\(index): \(item.formatDescription(drop: commonPath))"
            lines.insert(line, at: 0)
        }

        return lines
    }
}

public struct ResolvingStackItem: CustomStringConvertible {
    public let resolvingContainer: DependencyContainer
    public let registrationOwnerContainer: DependencyContainer
    public let dependencyKey: DependencyKey
    public let registrationPlace: DebugInfo
    public let resolutionPlace: DebugInfo
    
    init(dependencyKey: DependencyKey,
         resolvingContainer: DependencyContainer,
         ownerContainer: DependencyContainer,
         registrationPlace: DebugInfo,
         resolutionPlace: DebugInfo) {
        self.resolvingContainer = resolvingContainer
        self.registrationOwnerContainer = ownerContainer
        self.dependencyKey = dependencyKey
        self.registrationPlace = registrationPlace
        self.resolutionPlace = resolutionPlace
    }
    
    public var description: String {
        return formatDescription(drop: nil)
    }

    func formatDescription(drop commonPath: String?) -> String {
        return "resolving \(dependencyKey) at \(resolutionPlace.formatDescription(drop: commonPath))."
            + " Dependency registered at \(registrationPlace.formatDescription(drop: commonPath))."
            + " Containers: resolving – \(resolvingContainer.nameAndID); owner – \(registrationOwnerContainer.nameAndID)."
    }

    var allFileNames: [StaticString] {
        let registrationPlaceFiles = Array(sequence(first: registrationPlace, next: { $0.initiatedFrom }).map { $0.file })
        let resolutionPlaceFiles = Array(sequence(first: resolutionPlace, next: { $0.initiatedFrom }).map { $0.file })
        return registrationPlaceFiles + resolutionPlaceFiles
    }
}

private func getCommonPath(for fileNames: [String]) -> String? {
    guard let firstFile = fileNames.first, fileNames.count > 1 else { return nil }
    var path = firstFile.split(separator: "/", omittingEmptySubsequences: false).dropLast()
    var pathString = path.joined(separator: "/") + "/"

    if path.isEmpty { return nil }

    for file in fileNames.dropFirst() {
        if !file.starts(with: pathString) {
            let filePath = file.split(separator: "/", omittingEmptySubsequences: false).dropLast()

            let identicalComponentsCount = zip(path, filePath).prefix(while: { $0 == $1 }).count
            guard identicalComponentsCount > 1 else { return nil }

            path = filePath.prefix(identicalComponentsCount)
            pathString = path.joined(separator: "/") + "/"
        }
    }

    return pathString
}
