struct TypeHash: CustomStringConvertible, CustomDebugStringConvertible, Hashable {
    
    let type: Any.Type
    
    init(_ type: Any.Type) {
        self.type = type
    }
    
    public var description: String {
        return "TypeHash[\(type)]"
    }
    
    public var debugDescription: String {
        return "TypeHash[\(type), \(hashValue)]"
    }

    public func hash(into hasher: inout Hasher) {
        var type = self.type

        let address = withUnsafePointer(to: &type, { ptr in
            ptr.withMemoryRebound(to: Int.self, capacity: 1, { $0.pointee })
        })

        hasher.combine(address)
    }
    
    public static func ==(lhs: TypeHash, rhs: TypeHash) -> Bool {
        return lhs.type == rhs.type
    }
}
