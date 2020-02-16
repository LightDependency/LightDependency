import XCTest
import LightDependency

final class LifestyleTests: XCTestCase {

    func testSingleton() throws {
        var factoryCalled = 0
        let container = DependencyContainer(defaults: .registerSingletons) { context in
            context.register { _ -> Type1 in
                factoryCalled += 1
                return Type1("singleton")
            }
        }

        let value1: Type1 = try container.resolve()
        let value2: Type1 = try container.resolve()

        XCTAssert(value1 === value2)
        XCTAssertEqual(1, factoryCalled)
    }

    func testPerResolve() throws {
        var factoryCalled = 0
        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { context in
            context.register { _ -> Type1 in
                factoryCalled += 1
                return Type1("perResolve")
            }
        }

        let value1: Type1 = try container.resolve()
        let value2: Type1 = try container.resolve()

        XCTAssert(value1 !== value2)
        XCTAssertEqual(2, factoryCalled)
    }

    func testPerContainer() throws {
        var factoryCalled = 0
        let container = DependencyContainer(defaults: .createNewInstancePerContainer) { context in
            context.register { _ -> Type1 in
                factoryCalled += 1
                return Type1("perContainer")
            }
        }

        let value1FromRoot: Type1 = try container.resolve()
        let value2FromRoot: Type1 = try container.resolve()

        XCTAssert(value1FromRoot === value2FromRoot)
        XCTAssertEqual(1, factoryCalled)

        let childContainer = container.createChildContainer()
        let value1FromChild: Type1 = try childContainer.resolve()
        let value2FromChild: Type1 = try childContainer.resolve()

        XCTAssert(value1FromChild === value2FromChild)
        XCTAssert(value1FromRoot !== value1FromChild)
        XCTAssertEqual(2, factoryCalled)
    }

    func testNamedScope() throws {
        var factoryCalled = 0
        let container = DependencyContainer(defaults: .createNewInstancePerScope("myScope")) { context in
            context.register { _ -> Type1 in
                factoryCalled += 1
                return Type1("namedScope")
            }
        }

        let containerWithScope = container.createChildContainer(scopes: ["myScope"])

        let childContainer = containerWithScope.createChildContainer()

        XCTAssertThrowsError(try container.resolve() as Type1) { error in
            guard let error = error as? DependencyResolutionError,
                error.errorType == .scopeWasNotFoundUpToHierarchy else {
                    XCTFail("error should be DependencyResolutionError with type `scopeWasNotFoundUpToHierarchy`")
                    return
            }
        }

        XCTAssertEqual(0, factoryCalled)

        let value1FromContainerWithScope: Type1 = try containerWithScope.resolve()
        let value2FromContainerWithScope: Type1 = try containerWithScope.resolve()
        XCTAssert(value1FromContainerWithScope === value2FromContainerWithScope)
        XCTAssertEqual(1, factoryCalled)

        let value1FromChildContainer: Type1 = try childContainer.resolve()
        let value2FromChildContainer: Type1 = try childContainer.resolve()
        XCTAssert(value1FromChildContainer === value2FromChildContainer)
        XCTAssert(value1FromContainerWithScope === value1FromChildContainer)
        XCTAssertEqual(1, factoryCalled)
    }
}
