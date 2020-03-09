enum KnownDependency {

    /// single dependency that can be retrieved via `Resolver.resolve(file:, line:)` or `Resolver.resolve(byName:, file:, line:)`
    case single(DependencyKey)

    /// array of dependencies that can be retrieved via `Resolver.resolveAll(from:, file:, line:)`
    case array(Any.Type)

    /// named dependencies that can be retrieved via `Resolver.resolveNamed(from:, file:, line:)`
    case dictionary(Any.Type)
}

extension KnownDependency: Equatable {
    static func == (lhs: KnownDependency, rhs: KnownDependency) -> Bool {
        switch (lhs, rhs) {
        case let (.single(key1), .single(key2)):
            return key1 == key2

        case let (.array(type1), .array(type2)):
            return ObjectIdentifier(type1) == ObjectIdentifier(type2)

        case let (.dictionary(type1), .dictionary(type2)):
            return ObjectIdentifier(type1) == ObjectIdentifier(type2)

        default:
            return false
        }
    }
}
