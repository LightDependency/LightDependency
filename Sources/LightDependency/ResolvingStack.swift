public final class ResolvingStack: CustomStringConvertible {
    public let stack: [ResolvingStackItem]
    public let parentStack: ResolvingStack?

    init() {
        stack = []
        self.parentStack = nil
    }

    init(parentStack: ResolvingStack) {
        stack = []
        self.parentStack = parentStack
    }

    private init(stack: [ResolvingStackItem], parentStack: ResolvingStack?) {
        self.stack = stack
        self.parentStack = parentStack
    }

    func appening(_ stackItem: ResolvingStackItem) -> ResolvingStack {
        return ResolvingStack(stack: stack + [stackItem], parentStack: parentStack)
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

extension ResolvingStack {
    convenience init(queueInfo: ResolutionQueueInfo?) {
        guard let info = queueInfo else {
            self.init()
            return
        }

        let stackItems = sequence(first: info, next: { $0.parent }).reversed().map { $0.item }
        let parentStack = info.enqueuedFromItem.map { ResolvingStack(queueInfo: $0) }

        self.init(stack: stackItems, parentStack: parentStack)
    }
}

public struct ResolvingStackItem: CustomStringConvertible {
    public let dependencyKey: DependencyKey
    public let resolvingContainer: DependencyContainer
    public let registrationOwnerContainer: DependencyContainer
    public let registrationPlace: DebugInfo
    public let resolutionPlace: DebugInfo
    public let setUpPlace: DebugInfo?

    init(dependencyKey: DependencyKey,
         resolvingContainer: DependencyContainer,
         registrationOwnerContainer: DependencyContainer,
         registrationPlace: DebugInfo,
         resolutionPlace: DebugInfo,
         setUpPlace: DebugInfo?
    ) {
        self.dependencyKey = dependencyKey

        self.resolvingContainer = resolvingContainer
        self.registrationOwnerContainer = registrationOwnerContainer

        self.registrationPlace = registrationPlace
        self.resolutionPlace = resolutionPlace
        self.setUpPlace = setUpPlace
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
