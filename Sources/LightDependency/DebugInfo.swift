public final class DebugInfo: CustomStringConvertible {
    public let file: StaticString
    public let line: UInt

    public let initiatedFrom: DebugInfo?

    public init(file: StaticString, line: UInt, initiatedFrom: DebugInfo? = nil) {
        self.file = file
        self.line = line
        self.initiatedFrom = initiatedFrom
    }

    public var description: String {
        return formatDescription(drop: nil)
    }

    func formatDescription(drop commonPath: String?) -> String {
        let fileAndLine = file(byDropping: commonPath) + ":\(line)"
        if let parentInfo = initiatedFrom {
            return fileAndLine + "/" + parentInfo.formatDescription(drop: commonPath)
        }

        return fileAndLine
    }

    private func file(byDropping commonPath: String?) -> String {
        let file = String(describing: self.file)
        guard let commonPath = commonPath else { return file }
        guard file.starts(with: commonPath) else { return file }
        return String(file.dropFirst(commonPath.count))
    }
}
