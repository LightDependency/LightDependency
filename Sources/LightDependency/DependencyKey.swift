public struct DependencyKey: Equatable {
    public let type: Any.Type
    public let name: String?

    init(_ type: Any.Type, _ name: String?) {
        self.type = type
        self.name = name
    }
    
    public static func == (lhs: DependencyKey, rhs: DependencyKey) -> Bool {
        return lhs.type == rhs.type && lhs.name == rhs.name
    }
}

extension DependencyKey: CustomStringConvertible {
    public var description: String {
        return "[\(type)\( name.map { " \"\($0)\"" } ?? "" )]"
    }
}

extension DependencyKey: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type))
        hasher.combine(name)
    }
}
