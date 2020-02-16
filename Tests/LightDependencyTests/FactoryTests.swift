import XCTest
import LightDependency

final class FactoryTests: XCTestCase {

    func testCreateNoThrowableFabricWithNoArguments() throws {
        typealias Factory = () -> String

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerInstance("registered string")
        }

        let factory: Factory = try container.resolve()
        let string = factory()
        XCTAssertEqual(string, "registered string")
    }

    func testCreateThrowableFabricWithNoArguments() throws {
        typealias Factory = () throws -> String

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerInstance("registered string")
        }

        let factory: Factory = try container.resolve()
        let string = try factory()
        XCTAssertEqual(string, "registered string")
    }

    func testCreateNoThrowableFabricWithOneArgument() throws {
        typealias Factory = (Int) -> String

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in try "parameter: \(resolver.resolve() as Int)" }
        }

        let factory: Factory = try container.resolve()
        let string = factory(42)

        XCTAssertEqual(string, "parameter: 42")
    }

    func testCreateThrowableFabricWithOneArgument() throws {
        typealias Factory = (Int) throws -> String

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in try "parameter: \(resolver.resolve() as Int)" }
        }

        let factory: Factory = try container.resolve()
        let string = try factory(42)

        XCTAssertEqual(string, "parameter: 42")
    }

    func testCreateNoThrowableFabricWithTwoArguments() throws {
        typealias Factory = (Type1, Type2) -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = factory(Type1(), Type2())
        XCTAssertEqual(result.value, "1 2")
    }

    func testCreateThrowableFabricWithTwoArguments() throws {
        typealias Factory = (Type1, Type2) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = try factory(Type1(), Type2())
        XCTAssertEqual(result.value, "1 2")
    }

    func testCreateNoThrowableFabricWithThreeArguments() throws {
        typealias Factory = (Type1, Type2, Type3) -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve(), resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = factory(Type1(), Type2(), Type3())
        XCTAssertEqual(result.value, "1 2 3")
    }

    func testCreateThrowableFabricWithThreeArguments() throws {
        typealias Factory = (Type1, Type2, Type3) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve(), resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = try factory(Type1(), Type2(), Type3())
        XCTAssertEqual(result.value, "1 2 3")
    }

    func testCreateNoThrowableFabricWithFourArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4) -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve(), resolver.resolve(),
                resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = factory(Type1(), Type2(), Type3(), Type4())
        XCTAssertEqual(result.value, "1 2 3 4")
    }

    func testCreateThrowableFabricWithFourArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve(), resolver.resolve(),
                               resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = try factory(Type1(), Type2(), Type3(), Type4())
        XCTAssertEqual(result.value, "1 2 3 4")
    }

    func testCreateNoThrowableFabricWithFiveArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4, Type5) -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve(), resolver.resolve(),
                               resolver.resolve(), resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = factory(Type1(), Type2(), Type3(), Type4(), Type5())
        XCTAssertEqual(result.value, "1 2 3 4 5")
    }

    func testCreateThrowableFabricWithFiveArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4, Type5) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve(), resolver.resolve(),
                               resolver.resolve(), resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = try factory(Type1(), Type2(), Type3(), Type4(), Type5())
        XCTAssertEqual(result.value, "1 2 3 4 5")
    }

    func testCreateNoThrowableFabricWithSixArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4, Type5, Type6) -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve(), resolver.resolve(),
                               resolver.resolve(), resolver.resolve(), resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = factory(Type1(), Type2(), Type3(), Type4(), Type5(), Type6())
        XCTAssertEqual(result.value, "1 2 3 4 5 6")
    }

    func testCreateThrowableFabricWithSixArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4, Type5, Type6) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve(), resolver.resolve(),
                               resolver.resolve(), resolver.resolve(), resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = try factory(Type1(), Type2(), Type3(), Type4(), Type5(), Type6())
        XCTAssertEqual(result.value, "1 2 3 4 5 6")
    }

    func testCreateNoThrowableFabricWithSevenArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4, Type5, Type6, Type7) -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve(), resolver.resolve(),
                               resolver.resolve(), resolver.resolve(), resolver.resolve(),
                               resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = factory(Type1(), Type2(), Type3(), Type4(), Type5(), Type6(), Type7())
        XCTAssertEqual(result.value, "1 2 3 4 5 6 7")
    }

    func testCreateThrowableFabricWithSevenArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4, Type5, Type6, Type7) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.registerWithResolver { resolver in
                try ResultType(resolver.resolve(), resolver.resolve(), resolver.resolve(),
                               resolver.resolve(), resolver.resolve(), resolver.resolve(),
                               resolver.resolve())
            }
        }

        let factory: Factory = try container.resolve()
        let result = try factory(Type1(), Type2(), Type3(), Type4(), Type5(), Type6(), Type7())
        XCTAssertEqual(result.value, "1 2 3 4 5 6 7")
    }

    func testPropogateErrorWithNoArguments() throws {
        typealias Factory = () throws -> String

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.register { _ throws -> String in throw UserError() }
        }

        let factory: Factory = try container.resolve()
        XCTAssertThrowsError(try factory()) { error in
            XCTAssertTrue(error is UserError)
        }
    }

    func testPropogateErrorWithOneArgument() throws {
        typealias Factory = (Int) throws -> String

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.register { _ throws -> String in throw UserError() }
        }

        let factory: Factory = try container.resolve()
        XCTAssertThrowsError(try factory(1111)) { error in
            XCTAssertTrue(error is UserError)
        }
    }

    func testPropogateErrorWithTwoArguments() throws {
        typealias Factory = (Type1, Type2) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.register { _ throws -> ResultType in throw UserError() }
        }

        let factory: Factory = try container.resolve()
        XCTAssertThrowsError(try factory(Type1(), Type2())) { error in
            XCTAssertTrue(error is UserError)
        }
    }

    func testPropogateErrorWithThreeArguments() throws {
        typealias Factory = (Type1, Type2, Type3) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.register { _ throws -> ResultType in throw UserError() }
        }

        let factory: Factory = try container.resolve()
        XCTAssertThrowsError(try factory(Type1(), Type2(), Type3())) { error in
            XCTAssertTrue(error is UserError)
        }
    }

    func testPropogateErrorWithFourArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.register { _ throws -> ResultType in throw UserError() }
        }

        let factory: Factory = try container.resolve()
        XCTAssertThrowsError(try factory(Type1(), Type2(), Type3(), Type4())) { error in
            XCTAssertTrue(error is UserError)
        }
    }

    func testPropogateErrorWithFiveArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4, Type5) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.register { _ throws -> ResultType in throw UserError() }
        }

        let factory: Factory = try container.resolve()
        XCTAssertThrowsError(try factory(Type1(), Type2(), Type3(), Type4(), Type5())) { error in
            XCTAssertTrue(error is UserError)
        }
    }

    func testPropogateErrorWithSixArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4, Type5, Type6) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.register { _ throws -> ResultType in throw UserError() }
        }

        let factory: Factory = try container.resolve()
        XCTAssertThrowsError(try factory(Type1(), Type2(), Type3(), Type4(), Type5(), Type6())) { error in
            XCTAssertTrue(error is UserError)
        }
    }

    func testPropogateErrorWithSevenArguments() throws {
        typealias Factory = (Type1, Type2, Type3, Type4, Type5, Type6, Type7) throws -> ResultType

        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { ctx in
            ctx.registerFactory(Factory.self)
            ctx.register { _ throws -> ResultType in throw UserError() }
        }

        let factory: Factory = try container.resolve()
        XCTAssertThrowsError(try factory(Type1(), Type2(), Type3(), Type4(), Type5(), Type6(), Type7())) { error in
            XCTAssertTrue(error is UserError)
        }
    }
}
