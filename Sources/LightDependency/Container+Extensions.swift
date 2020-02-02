extension Container {
    public func resolve<Dependency>(file: StaticString = #file, line: UInt = #line) throws -> Dependency {
        return try resolve { resolver in try resolver.resolve(file: file, line: line) }
    }
}

private final class ContainerResolver: Resolver {
    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func resolve<T>(file: StaticString, line: UInt) throws -> T {
        return try container.resolve { try $0.resolve(file: file, line: line) }
    }

    func resolve<T>(byName name: String, file: StaticString, line: UInt) throws -> T {
        return try container.resolve { try $0.resolve(byName: name, file: file, line: line) }
    }

    func resolveAll<T>(from target: ResolveMultipleInstancesSearchTarget, file: StaticString, line: UInt) throws -> [T] {
        return try container.resolve { try $0.resolveAll(from: target, file: file, line: line) }
    }

    func resolveNamed<T>(from target: ResolveMultipleInstancesSearchTarget, file: StaticString, line: UInt) throws -> [String: T] {
        return try container.resolve { try $0.resolveNamed(from: target, file: file, line: line) }
    }
}

extension Container {
    public func asResolver() -> Resolver {
        return ContainerResolver(container: self)
    }
}
