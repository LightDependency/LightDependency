private typealias ChildContainerFactory = LightContainer.ChildContainerFactory

public struct FactoryRegistrationContext {
    private let context: RegistrationContext
    init(context: RegistrationContext) {
        self.context = context
    }
}

extension RegistrationContext {
    public var factoryContext: FactoryRegistrationContext {
        return FactoryRegistrationContext(context: self)
    }
}

extension FactoryRegistrationContext {
    public func register<Result>(
        _ type: (() -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Result.self, throwable: false, debugInfo: debugInfo)
    }

    public func register<Result>(
        _ type: (() throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Result.self, throwable: true, debugInfo: debugInfo)
    }

    public func register<Dep, Result>(
        _ type: ((Dep) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Result.self, throwable: false, debugInfo: debugInfo)
    }

    public func register<Dep, Result>(
        _ type: ((Dep) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Result.self, throwable: true, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Result>(
        _ type: ((Dep, Dep2) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Result.self, throwable: false, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Result>(
        _ type: ((Dep, Dep2) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Result.self, throwable: true, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Dep3, Result>(
        _ type: ((Dep, Dep2, Dep3) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Dep3.self, Result.self, throwable: false, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Dep3, Result>(
        _ type: ((Dep, Dep2, Dep3) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Dep3.self, Result.self, throwable: true, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Dep3, Dep4, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Dep3.self, Dep4.self, Result.self, throwable: false, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Dep3, Dep4, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Dep3.self, Dep4.self, Result.self, throwable: true, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Dep3.self, Dep4.self, Dep5.self, Result.self, throwable: false, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Dep3.self, Dep4.self, Dep5.self, Result.self, throwable: true, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Dep3.self, Dep4.self, Dep5.self, Dep6.self, Result.self, throwable: false, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Dep3.self, Dep4.self, Dep5.self, Dep6.self, Result.self, throwable: true, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7) -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Dep3.self, Dep4.self, Dep5.self, Dep6.self, Dep7.self, Result.self, throwable: false, debugInfo: debugInfo)
    }

    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Result>(
        _ type: ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7) throws -> Result).Type,
        file: StaticString = #file,
        line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line)
        registerFactory(Dep.self, Dep2.self, Dep3.self, Dep4.self, Dep5.self, Dep6.self, Dep7.self, Result.self, throwable: true, debugInfo: debugInfo)
    }
}

extension FactoryRegistrationContext {
    /// add registration for () [throws] -> Result
    private func registerFactory<Result>(_: Result.Type, throwable: Bool, debugInfo: DebugInfo) {
        typealias Factory = () throws -> Result
        typealias NoThrowableFactory = () -> Result
        
        func createFactory(resolver: Resolver) throws -> Factory {
            let container: Container = try resolver.resolve()
            return { () -> Result in
                return try container.resolve()
            }
        }

        switch throwable {
        case true:
            addRegistration(debugInfo, createFactory)

        case false:
            addRegistration(debugInfo) { resolver -> NoThrowableFactory in
                let factory = try! createFactory(resolver: resolver)
                return { try! factory() }
            }
        }
    }
    
    /// add registration for (Dep) [throws] -> Result
    private func registerFactory<Dep, Result>(_: Dep.Type, _: Result.Type, throwable: Bool, debugInfo: DebugInfo) {
        typealias Factory = (Dep) throws -> Result
        typealias NoThrowableFactory = (Dep) -> Result
        
        func createFactory(resolver: Resolver) throws -> Factory {
            let factory: ChildContainerFactory = try resolver.resolve()
            return { (dep: Dep) -> Result in
                let context = ChildContainerContext()
                context.addInstance(dep, initiatedFrom: debugInfo)
                let childContainer = factory(context)
                return try childContainer.resolve()
            }
        }

        switch throwable {
        case true:
            addRegistration(debugInfo, createFactory)

        case false:
            addRegistration(debugInfo) { resolver -> NoThrowableFactory in
                let factory = try! createFactory(resolver: resolver)
                return { dep in try! factory(dep) }
            }
        }
    }
    
    /// add registration for (Dep, Dep2) [throws] -> Result
    private func registerFactory<Dep, Dep2, Result>(_: Dep.Type, _: Dep2.Type, _: Result.Type, throwable: Bool, debugInfo: DebugInfo) {
        typealias Factory = (Dep, Dep2) throws -> Result
        typealias NoThrowableFactory = (Dep, Dep2) -> Result
        
        func createFactory(resolver: Resolver) throws -> Factory {
            let factory: ChildContainerFactory = try resolver.resolve()
            return { (dep: Dep, dep2: Dep2) -> Result in
                let context = ChildContainerContext()
                context.addInstance(dep, initiatedFrom: debugInfo)
                context.addInstance(dep2, initiatedFrom: debugInfo)
                let childContainer = factory(context)
                return try childContainer.resolve()
            }
        }

        switch throwable {
        case true:
            addRegistration(debugInfo, createFactory)

        case false:
            addRegistration(debugInfo) { resolver -> NoThrowableFactory in
                let factory = try! createFactory(resolver: resolver)
                return { dep, dep2 in try! factory(dep, dep2) }
            }
        }
    }
    
    /// add registration for (Dep, Dep2, Dep3) [throws] -> Result
    private func registerFactory<Dep, Dep2, Dep3, Result>(_: Dep.Type, _: Dep2.Type, _: Dep3.Type, _: Result.Type, throwable: Bool, debugInfo: DebugInfo) {
        typealias Factory = (Dep, Dep2, Dep3) throws -> Result
        typealias NoThrowableFactory = (Dep, Dep2, Dep3) -> Result
        
        func createFactory(resolver: Resolver) throws -> Factory {
            let factory: ChildContainerFactory = try resolver.resolve()
            return { (dep: Dep, dep2: Dep2, dep3: Dep3) -> Result in
                let context = ChildContainerContext()
                context.addInstance(dep, initiatedFrom: debugInfo)
                context.addInstance(dep2, initiatedFrom: debugInfo)
                context.addInstance(dep3, initiatedFrom: debugInfo)
                let childContainer = factory(context)
                return try childContainer.resolve()
            }
        }

        switch throwable {
        case true:
            addRegistration(debugInfo, createFactory)

        case false:
            addRegistration(debugInfo) { resolver -> NoThrowableFactory in
                let factory = try! createFactory(resolver: resolver)
                return { dep, dep2, dep3 in try! factory(dep, dep2, dep3) }
            }
        }
    }
    
    /// add registration for (Dep, Dep2, Dep3, Dep4) [throws] -> Result
    private func registerFactory<Dep, Dep2, Dep3, Dep4, Result>(_: Dep.Type, _: Dep2.Type, _: Dep3.Type, _: Dep4.Type, _: Result.Type, throwable: Bool, debugInfo: DebugInfo) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4) throws -> Result
        typealias NoThrowableFactory = (Dep, Dep2, Dep3, Dep4) -> Result
        
        func createFactory(resolver: Resolver) throws -> Factory {
            let factory: ChildContainerFactory = try resolver.resolve()
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4) -> Result in
                let context = ChildContainerContext()
                context.addInstance(dep, initiatedFrom: debugInfo)
                context.addInstance(dep2, initiatedFrom: debugInfo)
                context.addInstance(dep3, initiatedFrom: debugInfo)
                context.addInstance(dep4, initiatedFrom: debugInfo)
                let childContainer = factory(context)
                return try childContainer.resolve()
            }
        }

        switch throwable {
        case true:
            addRegistration(debugInfo, createFactory)

        case false:
            addRegistration(debugInfo) { resolver -> NoThrowableFactory in
                let factory = try! createFactory(resolver: resolver)
                return { dep, dep2, dep3, dep4 in try! factory(dep, dep2, dep3, dep4) }
            }
        }
    }
    
    /// add registration for (Dep, Dep2, Dep3, Dep4, Dep5) [throws] -> Result
    private func registerFactory<Dep, Dep2, Dep3, Dep4, Dep5, Result>(_: Dep.Type, _: Dep2.Type, _: Dep3.Type, _: Dep4.Type, _: Dep5.Type, _: Result.Type, throwable: Bool, debugInfo: DebugInfo) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4, Dep5) throws -> Result
        typealias NoThrowableFactory = (Dep, Dep2, Dep3, Dep4, Dep5) -> Result
        
        func createFactory(resolver: Resolver) throws -> Factory {
            let factory: ChildContainerFactory = try resolver.resolve()
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4, dep5: Dep5) -> Result in
                let context = ChildContainerContext()
                context.addInstance(dep, initiatedFrom: debugInfo)
                context.addInstance(dep2, initiatedFrom: debugInfo)
                context.addInstance(dep3, initiatedFrom: debugInfo)
                context.addInstance(dep4, initiatedFrom: debugInfo)
                context.addInstance(dep5, initiatedFrom: debugInfo)
                let childContainer = factory(context)
                return try childContainer.resolve()
            }
        }

        switch throwable {
        case true:
            addRegistration(debugInfo, createFactory)

        case false:
            addRegistration(debugInfo) { resolver -> NoThrowableFactory in
                let factory = try! createFactory(resolver: resolver)
                return { dep, dep2, dep3, dep4, dep5 in try! factory(dep, dep2, dep3, dep4, dep5) }
            }
        }
    }
    
    /// add registration for (Dep, Dep2, Dep3, Dep4, Dep5, Dep6) [throws] -> Result
    private func registerFactory<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Result>(_: Dep.Type, _: Dep2.Type, _: Dep3.Type, _: Dep4.Type, _: Dep5.Type, _: Dep6.Type, _: Result.Type, throwable: Bool, debugInfo: DebugInfo) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4, Dep5, Dep6) throws -> Result
        typealias NoThrowableFactory = (Dep, Dep2, Dep3, Dep4, Dep5, Dep6) -> Result
        
        func createFactory(resolver: Resolver) throws -> Factory {
            let factory: ChildContainerFactory = try resolver.resolve()
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4, dep5: Dep5, dep6: Dep6) -> Result in
                let context = ChildContainerContext()
                context.addInstance(dep, initiatedFrom: debugInfo)
                context.addInstance(dep2, initiatedFrom: debugInfo)
                context.addInstance(dep3, initiatedFrom: debugInfo)
                context.addInstance(dep4, initiatedFrom: debugInfo)
                context.addInstance(dep5, initiatedFrom: debugInfo)
                context.addInstance(dep6, initiatedFrom: debugInfo)
                let childContainer = factory(context)
                return try childContainer.resolve()
            }
        }

        switch throwable {
        case true:
            addRegistration(debugInfo, createFactory)

        case false:
            addRegistration(debugInfo) { resolver -> NoThrowableFactory in
                let factory = try! createFactory(resolver: resolver)
                return { dep, dep2, dep3, dep4, dep5, dep6 in try! factory(dep, dep2, dep3, dep4, dep5, dep6) }
            }
        }
    }
    
    /// add registration for (Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7) [throws] -> Result
    private func registerFactory<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Result>(_: Dep.Type, _: Dep2.Type, _: Dep3.Type, _: Dep4.Type, _: Dep5.Type, _: Dep6.Type, _: Dep7.Type, _: Result.Type, throwable: Bool, debugInfo: DebugInfo) {
        typealias Factory = (Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7) throws -> Result
        typealias NoThrowableFactory = (Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7) -> Result
        
        func createFactory(resolver: Resolver) throws -> Factory {
            let factory: ChildContainerFactory = try resolver.resolve()
            return { (dep: Dep, dep2: Dep2, dep3: Dep3, dep4: Dep4, dep5: Dep5, dep6: Dep6, dep7: Dep7) -> Result in
                let context = ChildContainerContext()
                context.addInstance(dep, initiatedFrom: debugInfo)
                context.addInstance(dep2, initiatedFrom: debugInfo)
                context.addInstance(dep3, initiatedFrom: debugInfo)
                context.addInstance(dep4, initiatedFrom: debugInfo)
                context.addInstance(dep5, initiatedFrom: debugInfo)
                context.addInstance(dep6, initiatedFrom: debugInfo)
                context.addInstance(dep7, initiatedFrom: debugInfo)
                let childContainer = factory(context)
                return try childContainer.resolve()
            }
        }

        switch throwable {
        case true:
            addRegistration(debugInfo, createFactory)

        case false:
            addRegistration(debugInfo) { resolver -> NoThrowableFactory in
                let factory = try! createFactory(resolver: resolver)
                return { dep, dep2, dep3, dep4, dep5, dep6, dep7 in try! factory(dep, dep2, dep3, dep4, dep5, dep6, dep7) }
            }
        }
    }
}

extension FactoryRegistrationContext {
    private func addRegistration<T>(_ debugInfo: DebugInfo, _ factory: @escaping (Resolver) throws -> T) {
        context.add(Registration(lifestyle: .perResolve, factory: factory), debugInfo: debugInfo)
    }
}

extension RegistrationContext {
    fileprivate func addInstance<T>(_ value: T, initiatedFrom: DebugInfo, file: StaticString = #file, line: UInt = #line) {
        let debugInfo = DebugInfo(file: file, line: line, initiatedFrom: initiatedFrom)
        add(Registration(lifestyle: .perResolve, factory: constant(value)), debugInfo: debugInfo)
    }
}
