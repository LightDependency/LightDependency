import XCTest
@testable import LightDependency

final class InitializerDependenciesTests: XCTestCase {

    func testDependenciesAreUnknownWhenUsedRegisterWithResolverMethod() {
        let container = DependencyContainer { context in
            context.registerWithResolver { resolver in
                ResultType(try resolver.resolve())
            }
        }

        assertDependencies(container: container, dependencies: nil)
    }

    func testFactoriesShouldNotHaveDependencies() {
        typealias Factory = (String) -> Int

        let container = DependencyContainer { context in
            context.registerFactory(Factory.self)
        }

        let registrations = container.registrationStorage
            .getRegistrations(for: DependencyKey(Factory.self, nil))

        XCTAssertEqual(1, registrations.count)

        guard let registration = registrations.first else { return }

        XCTAssertEqual([], registration.initializerDependencies)
    }

    func testInit0() {
        let container = DependencyContainer { context in
            context.register(InstanceWithoutDependencies.init)
        }

        let registrations = container.registrationStorage
            .getRegistrations(for: DependencyKey(InstanceWithoutDependencies.self, nil))

        XCTAssertEqual(1, registrations.count)

        guard let registration = registrations.first else { return }

        XCTAssertEqual([], registration.initializerDependencies)
    }

    func testInit1() {
        let container = DependencyContainer { context in
            context.register(ResultType.init(_:))
        }

        assertDependencies(
            container: container,
            dependencies: [
                .single(DependencyKey(Type1.self, nil))
        ])
    }

    func testInit2() {
        let container = DependencyContainer { context in
            context.register(ResultType.init(_:_:))
        }

        assertDependencies(
            container: container,
            dependencies: [
                .single(DependencyKey(Type1.self, nil)),
                .single(DependencyKey(Type2.self, nil))
        ])
    }

    func testInit3() {
        let container = DependencyContainer { context in
            context.register(ResultType.init(_:_:_:))
        }

        assertDependencies(
            container: container,
            dependencies: [
                .single(DependencyKey(Type1.self, nil)),
                .single(DependencyKey(Type2.self, nil)),
                .single(DependencyKey(Type3.self, nil))
        ])
    }

    func testInit4() {
        let container = DependencyContainer { context in
            context.register(ResultType.init(_:_:_:_:))
        }

        assertDependencies(
            container: container,
            dependencies: [
                .single(DependencyKey(Type1.self, nil)),
                .single(DependencyKey(Type2.self, nil)),
                .single(DependencyKey(Type3.self, nil)),
                .single(DependencyKey(Type4.self, nil))
        ])
    }

    func testInit5() {
        let container = DependencyContainer { context in
            context.register(ResultType.init(_:_:_:_:_:))
        }

        assertDependencies(
            container: container,
            dependencies: [
                .single(DependencyKey(Type1.self, nil)),
                .single(DependencyKey(Type2.self, nil)),
                .single(DependencyKey(Type3.self, nil)),
                .single(DependencyKey(Type4.self, nil)),
                .single(DependencyKey(Type5.self, nil))
        ])
    }

    func testInit6() {
        let container = DependencyContainer { context in
            context.register(ResultType.init(_:_:_:_:_:_:))
        }

        assertDependencies(
            container: container,
            dependencies: [
                .single(DependencyKey(Type1.self, nil)),
                .single(DependencyKey(Type2.self, nil)),
                .single(DependencyKey(Type3.self, nil)),
                .single(DependencyKey(Type4.self, nil)),
                .single(DependencyKey(Type5.self, nil)),
                .single(DependencyKey(Type6.self, nil))
        ])
    }

    func testInit7() {
        let container = DependencyContainer { context in
            context.register(ResultType.init(_:_:_:_:_:_:_:))
        }

        assertDependencies(
            container: container,
            dependencies: [
                .single(DependencyKey(Type1.self, nil)),
                .single(DependencyKey(Type2.self, nil)),
                .single(DependencyKey(Type3.self, nil)),
                .single(DependencyKey(Type4.self, nil)),
                .single(DependencyKey(Type5.self, nil)),
                .single(DependencyKey(Type6.self, nil)),
                .single(DependencyKey(Type7.self, nil))
        ])
    }

    private func assertDependencies(container: DependencyContainer, dependencies: [KnownDependency]?) {
        let registrations = container.registrationStorage
            .getRegistrations(for: DependencyKey(ResultType.self, nil))

        XCTAssertEqual(1, registrations.count)

        guard let registration = registrations.first else { return }

        XCTAssertEqual(dependencies, registration.initializerDependencies)
    }
}
