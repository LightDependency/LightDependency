enum KnownDependency {

    /// single dependency that can be retrieved via `Resolver.resolve(file:, line:)` or `Resolver.resolve(byName:, file:, line:)`
    case single(DependencyKey)

    /// array of dependencies that can be retrieved via `Resolver.resolveAll(from:, file:, line:)`
    case array(Any.Type)

    /// named dependencies that can be retrieved via `Resolver.resolveNamed(from:, file:, line:)`
    case dictionary(Any.Type)
}
