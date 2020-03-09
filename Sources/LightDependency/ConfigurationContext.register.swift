extension ConfigurationContext {

    @inline(__always)
    func _register<Instance>(
        debugInfo: DebugInfo,
        initializerDependencies: [KnownDependency],
        _ factory: @escaping (ResolverType) throws -> Instance
    ) -> RegistrationConfig<Instance> {

        let config = RegistrationConfig(
            factory: factory,
            initializerDependencies: initializerDependencies,
            defaultLifestyle: defaultLifestyle,
            debugInfo: debugInfo
        )

        addAction(config.addToContext(_:))
        return config
    }

    @discardableResult
    public func register<Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping (()) throws -> Instance
    ) -> RegistrationConfig<Instance> {
        _register(
            debugInfo: DebugInfo(file: file, line: line),
            initializerDependencies: []
        ) { _ in
            try factory(())
        }
    }

    @discardableResult
    public func register<Dep, Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping (Dep) throws -> Instance
    ) -> RegistrationConfig<Instance> {
        _register(
            debugInfo: DebugInfo(file: file, line: line),
            initializerDependencies: [.single(DependencyKey(Dep.self, nil))]
        ) { resolver in
            try factory(resolver.resolve(file: file, line: line))
        }
    }

    @discardableResult
    public func register<Dep, Dep2, Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2)) throws -> Instance
    ) -> RegistrationConfig<Instance> {
        _register(
            debugInfo: DebugInfo(file: file, line: line),
            initializerDependencies: [
                .single(DependencyKey(Dep.self, nil)),
                .single(DependencyKey(Dep2.self, nil))
            ]
        ) { resolver in
            try factory(resolver.resolveFew(file: file, line: line))
        }
    }

    @discardableResult
    public func register<Dep, Dep2, Dep3, Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2, Dep3)) throws -> Instance
    ) -> RegistrationConfig<Instance> {
        _register(
            debugInfo: DebugInfo(file: file, line: line),
            initializerDependencies: [
                .single(DependencyKey(Dep.self, nil)),
                .single(DependencyKey(Dep2.self, nil)),
                .single(DependencyKey(Dep3.self, nil))
            ]
        ) { resolver in
            try factory(resolver.resolveFew(file: file, line: line))
        }
    }

    @discardableResult
    public func register<Dep, Dep2, Dep3, Dep4, Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2, Dep3, Dep4)) throws -> Instance
    ) -> RegistrationConfig<Instance> {
        _register(
            debugInfo: DebugInfo(file: file, line: line),
            initializerDependencies: [
                .single(DependencyKey(Dep.self, nil)),
                .single(DependencyKey(Dep2.self, nil)),
                .single(DependencyKey(Dep3.self, nil)),
                .single(DependencyKey(Dep4.self, nil))
            ]
        ) { resolver in
            try factory(resolver.resolveFew(file: file, line: line))
        }
    }

    @discardableResult
    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2, Dep3, Dep4, Dep5)) throws -> Instance
    ) -> RegistrationConfig<Instance> {
        _register(
            debugInfo: DebugInfo(file: file, line: line),
            initializerDependencies: [
                .single(DependencyKey(Dep.self, nil)),
                .single(DependencyKey(Dep2.self, nil)),
                .single(DependencyKey(Dep3.self, nil)),
                .single(DependencyKey(Dep4.self, nil)),
                .single(DependencyKey(Dep5.self, nil))
            ]
        ) { resolver in
            try factory(resolver.resolveFew(file: file, line: line))
        }
    }

    @discardableResult
    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6)) throws -> Instance
    ) -> RegistrationConfig<Instance> {
        _register(
            debugInfo: DebugInfo(file: file, line: line),
            initializerDependencies: [
                .single(DependencyKey(Dep.self, nil)),
                .single(DependencyKey(Dep2.self, nil)),
                .single(DependencyKey(Dep3.self, nil)),
                .single(DependencyKey(Dep4.self, nil)),
                .single(DependencyKey(Dep5.self, nil)),
                .single(DependencyKey(Dep6.self, nil))
            ]
        ) { resolver in
            try factory(resolver.resolveFew(file: file, line: line))
        }
    }

    @discardableResult
    public func register<Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7, Instance>(
        file: StaticString = #file,
        line: UInt = #line,
        _ factory: @escaping ((Dep, Dep2, Dep3, Dep4, Dep5, Dep6, Dep7)) throws -> Instance
    ) -> RegistrationConfig<Instance> {
        _register(
            debugInfo: DebugInfo(file: file, line: line),
            initializerDependencies: [
                .single(DependencyKey(Dep.self, nil)),
                .single(DependencyKey(Dep2.self, nil)),
                .single(DependencyKey(Dep3.self, nil)),
                .single(DependencyKey(Dep4.self, nil)),
                .single(DependencyKey(Dep5.self, nil)),
                .single(DependencyKey(Dep6.self, nil)),
                .single(DependencyKey(Dep7.self, nil))
            ]
        ) { resolver in
            try factory(resolver.resolveFew(file: file, line: line))
        }
    }
}
