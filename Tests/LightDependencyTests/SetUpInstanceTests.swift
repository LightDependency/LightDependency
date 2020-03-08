import XCTest
import LightDependency

final class SetUpInstanceTests: XCTestCase {

    func testSetUpForTransientDependency() throws {
        var setUpCounter = 0

        let container = DependencyContainer { context in
            context.register(TestDependency.init)
                .setUp { _, _ in setUpCounter += 1 }
        }

        let _: TestDependency = try container.resolve()
        XCTAssertEqual(1, setUpCounter, "setUp closure should be called")
    }

    func testSetUpOrderShouldBePreserved() throws {
        var setUpOrder: [Int] = []
        let container = DependencyContainer { context in
            context.register(TestDependency.init)
                .setUp { _, _ in setUpOrder.append(0) }
                .setUp { _, _ in setUpOrder.append(1) }
                .setUp { _, _ in setUpOrder.append(2) }
                .setUp { _, _ in setUpOrder.append(3) }
                .setUp { _, _ in setUpOrder.append(4) }
                .setUp { _, _ in setUpOrder.append(5) }
        }

        let _: TestDependency = try container.resolve()
        XCTAssertEqual([0, 1, 2, 3, 4, 5], setUpOrder)
    }

    func testResolvingCircularSingletonDependencies_A() throws {
        let container = DependencyContainer { context in
            context.register(DependencyA.init(b:)).asSingleton()
            context.register(DependencyB.init).asSingleton()
                .setUp { instance, resolver in
                    instance.a = try resolver.resolve()
            }
        }

        let dependencyA: DependencyA = try container.resolve()
        XCTAssertNotNil(dependencyA.b?.a)
        XCTAssertTrue(dependencyA === dependencyA.b?.a)
    }

    func testResolvingCircularSingletonDependencies_B() throws {
        let container = DependencyContainer { context in
            context.register(DependencyA.init(b:)).asSingleton()
            context.register(DependencyB.init).asSingleton()
                .setUp { instance, resolver in
                    instance.a = try resolver.resolve()
            }
        }

        let dependencyB: DependencyB = try container.resolve()
        XCTAssertNotNil(dependencyB.a)
    }

    func testResolvingCircularContainerDependencies_A() throws {
        let container = DependencyContainer { context in
            context.register(DependencyA.init(b:)).perContainer()
            context.register(DependencyB.init).perContainer()
                .setUp { instance, resolver in
                    instance.a = try resolver.resolve()
            }
        }

        let dependencyA: DependencyA = try container.resolve()
        XCTAssertNotNil(dependencyA.b?.a)
        XCTAssertTrue(dependencyA === dependencyA.b?.a)
    }

    func testResolvingCircularContainerDependencies_B() throws {
        let container = DependencyContainer { context in
            context.register(DependencyA.init(b:)).perContainer()
            context.register(DependencyB.init).perContainer()
                .setUp { instance, resolver in
                    instance.a = try resolver.resolve()
            }
        }

        let dependencyB: DependencyB = try container.resolve()
        XCTAssertNotNil(dependencyB.a)
    }

    func testResolvingCircularScopedDependencies_A() throws {
        let container = DependencyContainer { context in
            context.register(DependencyA.init(b:)).asScoped("scope")
            context.register(DependencyB.init).asScoped("scope")
                .setUp { instance, resolver in
                    instance.a = try resolver.resolve()
            }
        }

        let childContainer = container.createChildContainer(scopes: ["scope"])

        let dependencyA: DependencyA = try childContainer.resolve()
        XCTAssertNotNil(dependencyA.b?.a)
        XCTAssertTrue(dependencyA === dependencyA.b?.a)
    }

    func testResolvingCircularScopedDependencies_B() throws {
        let container = DependencyContainer { context in
            context.register(DependencyA.init(b:)).asScoped("scope")
            context.register(DependencyB.init).asScoped("scope")
                .setUp { instance, resolver in
                    instance.a = try resolver.resolve()
            }
        }

        let childContainer = container.createChildContainer(scopes: ["scope"])

        let dependencyB: DependencyB = try childContainer.resolve()
        XCTAssertNotNil(dependencyB.a)
    }

    func testResolving3CircularSingletonDependencies() throws {
        let container = DependencyContainer { context in
            context.register(DependencyA.init(b:)).asSingleton()
            context.register(DependencyB.init).asSingleton()
                .setUp { instance, resolver in
                    instance.c = try resolver.resolve()
            }
            context.register(DependencyC.init(_:)).asSingleton()
        }

        let dependencyA: DependencyA = try container.resolve()
        XCTAssertNotNil(dependencyA.b?.c)
        XCTAssertTrue(dependencyA === dependencyA.b?.c?.a)
    }

    func testSetUpOrder() throws {
        var operations: [String] = []

        let container = DependencyContainer { context in
            context.registerWithResolver { resolver -> DependencyA in
                operations.append("resolve A")
                return DependencyA(b: try resolver.resolve())
            }
            .asSingleton()
            .setUp {
                operations.append("set up A")
                $0.z = try $1.resolve()
            }

            context.registerWithResolver { resolver -> DependencyB in
                operations.append("resolve B")
                return DependencyB(c: try resolver.resolve())
            }
            .asSingleton()
            .setUp {
                operations.append("set up B")
                $0.z = try $1.resolve()
            }

            context.register { () -> DependencyC in
                operations.append("resolve C")
                return DependencyC()
            }.asSingleton()

            context.register { () -> DependencyZ in
                operations.append("resolve Z")
                return DependencyZ()
            }
            .asSingleton()
            .setUp {
                operations.append("set up Z")
                $0.y = try $1.resolve()
            }

            context.registerWithResolver { resolver -> DependencyY in
                operations.append("resolve Y")
                return DependencyY(z: try resolver.resolve())
            }.asSingleton()
        }

        let _: DependencyA = try container.resolve()
        let expectedOperations = [
            "resolve A",
            "resolve B",
            "resolve C",
            "set up B",
            "resolve Z",
            "set up Z",
            "resolve Y",
            "set up A"
        ]

        XCTAssertEqual(expectedOperations, operations)
    }
}

private class TestDependency {
    init() { }
}

private class DependencyA {
    var a: DependencyA?
    var b: DependencyB?
    var c: DependencyC?
    var z: DependencyZ?

    init(b: DependencyB) {
        self.b = b
    }
}

private class DependencyB {
    init() {
    }

    var a: DependencyA?
    var b: DependencyB?
    var c: DependencyC?
    var z: DependencyZ?

    init(c: DependencyC) {
        self.c = c
    }
}

private class DependencyC {
    var a: DependencyA?

    init() {
    }

    init(_ a: DependencyA) {
        self.a = a
    }
}

private class DependencyZ {
    var y: DependencyY?

    init() {
    }

    init(y: DependencyY) {
        self.y = y
    }
}

private class DependencyY {
    var z: DependencyZ?

    init() {
    }

    init(z: DependencyZ) {
        self.z = z
    }
}
