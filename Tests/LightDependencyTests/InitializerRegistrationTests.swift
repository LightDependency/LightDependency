import XCTest
import LightDependency

final class InitializerRegistrationTests: XCTestCase {

    private func registerDefaultTypes(_ context: ConfigurationContext) {
        context.register { Type1() }
        context.register { Type2() }
        context.register { Type3() }
        context.register { Type4() }
        context.register { Type5() }
        context.register { Type6() }
        context.register { Type7() }
    }

    func testResolveResolvable0() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            registerDefaultTypes(context)
            context.register(Resolvable0.init)
        }

        XCTAssertNoThrow(try container.resolve() as Resolvable0)
    }

    func testResolveResolvable1() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            registerDefaultTypes(context)
            context.register(Resolvable1.init)
        }

        XCTAssertNoThrow(try container.resolve() as Resolvable1)
    }

    func testResolveResolvable2() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            registerDefaultTypes(context)
            context.register(Resolvable2.init)
        }

        XCTAssertNoThrow(try container.resolve() as Resolvable2)
    }

    func testResolveResolvable3() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            registerDefaultTypes(context)
            context.register(Resolvable3.init)
        }

        XCTAssertNoThrow(try container.resolve() as Resolvable3)
    }

    func testResolveResolvable4() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            registerDefaultTypes(context)
            context.register(Resolvable4.init)
        }

        XCTAssertNoThrow(try container.resolve() as Resolvable4)
    }

    func testResolveResolvable5() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            registerDefaultTypes(context)
            context.register(Resolvable5.init)
        }

        XCTAssertNoThrow(try container.resolve() as Resolvable5)
    }

    func testResolveResolvable6() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            registerDefaultTypes(context)
            context.register(Resolvable6.init)
        }

        XCTAssertNoThrow(try container.resolve() as Resolvable6)
    }

    func testResolveResolvable7() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            registerDefaultTypes(context)
            context.register(Resolvable7.init)
        }

        XCTAssertNoThrow(try container.resolve() as Resolvable7)
    }
}

final class Resolvable0 {
    init() {
    }
}

final class Resolvable1 {
    init(_ t: Type1) {
    }
}

final class Resolvable2 {
    init(_ t1: Type1, _ t2: Type2) {
    }
}

final class Resolvable3 {
    init(_ t1: Type1, _ t2: Type2, _ t3: Type3) throws {
    }
}

final class Resolvable4 {
    init(_ t1: Type1, t2: Type2, _ t3: Type3, _ t4: Type4) {
    }
}

final class Resolvable5 {
    init(_ t1: Type1, t2: Type2, _ t3: Type3, t4: Type4, _ t5: Type5) throws {
    }
}

final class Resolvable6 {
    init(_ t1: Type1, _ t2: Type2, _ t3: Type3, _ t4: Type4, _ t5: Type5, _ t6: Type6) {
    }
}

final class Resolvable7 {
    init(_ t1: Type1, _ t2: Type2, _ t3: Type3, _ t4: Type4, _ t5: Type5, _ t6: Type6, _ t7: Type7) {
    }
}
