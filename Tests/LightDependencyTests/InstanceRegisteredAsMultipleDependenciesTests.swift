import XCTest
import LightDependency

final class InstanceRegisteredAsMultipleDependenciesTests: XCTestCase {

    func testSingletonInstanceShouldBeCreatedOnceForMultipleDependencies() throws {
        var factoryCallCounter = 0

        let container = DependencyContainer(defaults: .registerSingletons) { context in
            context
                .register { () -> SuperService in
                    factoryCallCounter += 1
                    return SuperService()
                }
                .asDependency(ofType: { $0 as Service1Type })
                .asDependency(ofType: { $0 as Service2Type })
                .asDependency(ofType: { AnyServiceWithAssociatedType($0) })
        }

        let _: Service1Type = try container.resolve()
        let _: Service2Type = try container.resolve()
        let _: AnyServiceWithAssociatedType<String> = try container.resolve()

        XCTAssertEqual(1, factoryCallCounter)
    }
}
