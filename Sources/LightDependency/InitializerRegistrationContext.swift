public struct InitializerRegistrationContext {
    private let context: ConfiguarationContext
    init(context: ConfiguarationContext) {
        self.context = context
    }
}

extension ConfiguarationContext {
    public var initContext: InitializerRegistrationContext {
        return InitializerRegistrationContext(context: self)
    }
}

extension InitializerRegistrationContext {
    @discardableResult
    public func register<Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping (()) throws -> Result)
        -> RegistrationConfig<Result> {
            return context.register(file: file, line: line) { _ in
                try factory(())
            }
    }

    @discardableResult
    public func register<Dep, Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping (Dep) throws -> Result)
        -> RegistrationConfig<Result> {
            return context.register(file: file, line: line) { resolver in
                try factory(resolver.resolve(file: file, line: line))
            }
    }

    @discardableResult
    public func register<Dep, Dep2, Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2)) throws -> Result)
        -> RegistrationConfig<Result> {
            return context.register(file: file, line: line) { resolver in
                try factory(resolver.resolveFew(file: file, line: line))
            }
    }

    @discardableResult
    public func register<Dep, Dep2, Dep3, Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2, Dep3)) throws -> Result)
        -> RegistrationConfig<Result> {
            return context.register(file: file, line: line) { resolver in
                try factory(resolver.resolveFew(file: file, line: line))
            }
    }

    @discardableResult
    public func register<Dep, Dep2, Dep3, Dep4, Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2, Dep3, Dep4)) throws -> Result)
        -> RegistrationConfig<Result> {
            return context.register(file: file, line: line) { resolver in
                try factory(resolver.resolveFew(file: file, line: line))
            }
    }

    @discardableResult
    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2, Dep3, Dep4, Dep5)) throws -> Result)
        -> RegistrationConfig<Result> {
            return context.register(file: file, line: line) { resolver in
                try factory(resolver.resolveFew(file: file, line: line))
            }
    }

    @discardableResult
    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6)) throws -> Result)
        -> RegistrationConfig<Result> {
            return context.register(file: file, line: line) { resolver in
                try factory(resolver.resolveFew(file: file, line: line))
            }
    }

    @discardableResult
    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7)) throws -> Result)
        -> RegistrationConfig<Result> {
            return context.register(file: file, line: line) { resolver in
                try factory(resolver.resolveFew(file: file, line: line))
            }
    }
}
