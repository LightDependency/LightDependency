public final class ContainerResolver: ResolverType {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    public func resolve<T>(file: StaticString, line: UInt) throws -> T {
        return try container.resolve { try $0.resolve(file: file, line: line) }
    }

    public func resolve<T>(byName name: String, file: StaticString, line: UInt) throws -> T {
        return try container.resolve { try $0.resolve(byName: name, file: file, line: line) }
    }

    public func resolveAll<T>(from target: ResolveMultipleInstancesSearchTarget, file: StaticString, line: UInt) throws -> [T] {
        return try container.resolve { try $0.resolveAll(from: target, file: file, line: line) }
    }

    public func resolveNamed<T>(from target: ResolveMultipleInstancesSearchTarget, file: StaticString, line: UInt) throws -> [String: T] {
        return try container.resolve { try $0.resolveNamed(from: target, file: file, line: line) }
    }
}

extension DependencyContainer {
    public func asResolver() -> ContainerResolver {
        return ContainerResolver(container: self)
    }
}
