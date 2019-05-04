public struct DependencyKey: CustomStringConvertible, Equatable {
    public let type: Any.Type
    public let name: String?
    
    init(_ type: Any.Type, _ name: String?) {
        self.type = type
        self.name = name
    }
    
    public var description: String {
        return "[\(type)\( name.map { " \"\($0)\"" } ?? "" )]"
    }
    
    public static func == (lhs: DependencyKey, rhs: DependencyKey) -> Bool {
        return lhs.type == rhs.type && lhs.name == rhs.name
    }
}
