public enum ResolveMultipleInstancesSearchTarget {
    case nearestContainer
    case containerHierarchy
}

public protocol Resolver {
    func resolve<T>(file: StaticString, line: UInt) throws -> T
    func resolve<T>(byName name: String, file: StaticString, line: UInt) throws -> T
    func resolveAll<T>(from target: ResolveMultipleInstancesSearchTarget, file: StaticString, line: UInt) throws -> [T]
    func resolveNamed<T>(from target: ResolveMultipleInstancesSearchTarget, file: StaticString, line: UInt) throws -> [String: T]
}

public extension Resolver {
    func resolve<T>(_ file: StaticString = #file, _ line: UInt = #line) throws -> T {
        return try resolve(file: file, line: line)
    }

    func resolve<T>(byName name: String, _ file: StaticString = #file, _ line: UInt = #line) throws -> T {
        return try resolve(byName: name, file: file, line: line)
    }
}

public extension Resolver {
    func resolveAll<T>(
        from target: ResolveMultipleInstancesSearchTarget = .nearestContainer,
        _ file: StaticString = #file,
        _ line: UInt = #line)
        throws -> [T] {
            return try resolveAll(from: target, file: file, line: line)
    }

    func resolveNamed<T>(
        from target: ResolveMultipleInstancesSearchTarget = .nearestContainer,
        _ file: StaticString = #file,
        _ line: UInt = #line)
        throws -> [String: T] {
            return try resolveNamed(from: target, file: file, line: line)
    }
}

public extension Resolver {
    func resolveFew<T, T2>(file: StaticString = #file, line: UInt = #line)
        throws -> (T, T2) {
            return try (resolve(file: file, line: line),
                        resolve(file: file, line: line))
    }

    func resolveFew<T, T2, T3>(file: StaticString = #file, line: UInt = #line)
        throws -> (T, T2, T3) {
            return try (resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line))
    }

    func resolveFew<T, T2, T3, T4>(file: StaticString = #file, line: UInt = #line)
        throws -> (T, T2, T3, T4) {
            return try (resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line))
    }

    func resolveFew<T, T2, T3, T4, T5>(file: StaticString = #file, line: UInt = #line)
        throws -> (T, T2, T3, T4, T5) {
            return try (resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line))
    }

    func resolveFew<T, T2, T3, T4, T5, T6>(file: StaticString = #file, line: UInt = #line)
        throws -> (T, T2, T3, T4, T5, T6) {
            return try (resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line))
    }

    func resolveFew<T, T2, T3, T4, T5, T6, T7>(file: StaticString = #file, line: UInt = #line)
        throws -> (T, T2, T3, T4, T5, T6, T7) {
            return try (resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line),
                        resolve(file: file, line: line))
    }
}
