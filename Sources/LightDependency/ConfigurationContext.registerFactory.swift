extension ConfigurationContext {

    public func registerFactory<Result>(
        _ type: (() -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = () -> Result
        addRegistration(DebugInfo(file: file, line: line)) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { () -> Result in
                return try! resolvingContainer.resolve()
            }
        }
    }

    public func registerFactory<Result>(
        _ type: (() throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = () throws -> Result
        addRegistration(DebugInfo(file: file, line: line)) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { () -> Result in
                return try resolvingContainer.resolve()
            }
        }
    }

    public func registerFactory<Dep, Result>(
        _ type: ((Dep) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep) -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                }

                return try! container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Result>(
        _ type: ((Dep) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep) throws -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                }

                return try container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Result>(
        _ type: ((Dep, Dep2) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2) -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                }

                return try! container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Result>(
        _ type: ((Dep, Dep2) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2) throws -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                }

                return try container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Dep3, Result>(
        _ type: ((Dep, Dep2, Dep3) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2, Dep3) -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2, dep3: Dep3) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                    $0.addInstance(dep3, initiatedFrom: debugInfo)
                }

                return try! container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Dep3, Result>(
        _ type: ((Dep, Dep2, Dep3) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2, Dep3) throws -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2, dep3: Dep3) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                    $0.addInstance(dep3, initiatedFrom: debugInfo)
                }

                return try container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Dep3, Dep4, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4) -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                    $0.addInstance(dep3, initiatedFrom: debugInfo)
                    $0.addInstance(dep4, initiatedFrom: debugInfo)
                }

                return try! container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Dep3, Dep4, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4) throws -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                    $0.addInstance(dep3, initiatedFrom: debugInfo)
                    $0.addInstance(dep4, initiatedFrom: debugInfo)
                }

                return try container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Dep3, Dep4, Dep5, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4, Dep5) -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4, dep5: Dep5) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                    $0.addInstance(dep3, initiatedFrom: debugInfo)
                    $0.addInstance(dep4, initiatedFrom: debugInfo)
                    $0.addInstance(dep5, initiatedFrom: debugInfo)
                }

                return try! container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Dep3, Dep4, Dep5, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4, Dep5) throws -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4, dep5: Dep5) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                    $0.addInstance(dep3, initiatedFrom: debugInfo)
                    $0.addInstance(dep4, initiatedFrom: debugInfo)
                    $0.addInstance(dep5, initiatedFrom: debugInfo)
                }

                return try container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4, Dep5, Dep6) -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4, dep5: Dep5, dep6: Dep6) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                    $0.addInstance(dep3, initiatedFrom: debugInfo)
                    $0.addInstance(dep4, initiatedFrom: debugInfo)
                    $0.addInstance(dep5, initiatedFrom: debugInfo)
                    $0.addInstance(dep6, initiatedFrom: debugInfo)
                }

                return try! container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4, Dep5, Dep6) throws -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4, dep5: Dep5, dep6: Dep6) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                    $0.addInstance(dep3, initiatedFrom: debugInfo)
                    $0.addInstance(dep4, initiatedFrom: debugInfo)
                    $0.addInstance(dep5, initiatedFrom: debugInfo)
                    $0.addInstance(dep6, initiatedFrom: debugInfo)
                }

                return try container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7) -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4, dep5: Dep5, dep6: Dep6, dep7: Dep7) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                    $0.addInstance(dep3, initiatedFrom: debugInfo)
                    $0.addInstance(dep4, initiatedFrom: debugInfo)
                    $0.addInstance(dep5, initiatedFrom: debugInfo)
                    $0.addInstance(dep6, initiatedFrom: debugInfo)
                    $0.addInstance(dep7, initiatedFrom: debugInfo)
                }

                return try! container.resolve()
            }
        }
    }

    public func registerFactory<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7) throws -> Result
        let debugInfo = DebugInfo(file: file, line: line)
        addRegistration(debugInfo) { resolver -> Factory in
            let resolvingContainer = resolver.resolvingContainer
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4, dep5: Dep5, dep6: Dep6, dep7: Dep7) -> Result in
                let container = resolvingContainer.createChildContainer {
                    $0.addInstance(dep, initiatedFrom: debugInfo)
                    $0.addInstance(dep2, initiatedFrom: debugInfo)
                    $0.addInstance(dep3, initiatedFrom: debugInfo)
                    $0.addInstance(dep4, initiatedFrom: debugInfo)
                    $0.addInstance(dep5, initiatedFrom: debugInfo)
                    $0.addInstance(dep6, initiatedFrom: debugInfo)
                    $0.addInstance(dep7, initiatedFrom: debugInfo)
                }

                return try container.resolve()
            }
        }
    }
}

extension ConfigurationContext {
    private func addRegistration<T>(_ debugInfo: DebugInfo, _ factory: @escaping (Resolver) throws -> T) {
        addTransientRegistration(factory: factory, debugInfo: debugInfo)
    }

    private func addInstance<T>(_ value: T, initiatedFrom: DebugInfo, file: StaticString = #file, line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line, initiatedFrom: initiatedFrom)
        addTransientRegistration(factory: { _ in value }, debugInfo: debugInfo)
    }

    @inline(__always)
    private func addTransientRegistration<T>(factory: @escaping (Resolver) throws -> T, debugInfo: DebugInfo) {
        add(Registration(name: nil, lifestyle: .transient, factory: factory, setUpActions: [], casting: { $0 }, debugInfo: debugInfo))
    }
}
