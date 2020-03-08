import XCTest
import LightDependency

final class ResolveOptionalsTests: XCTestCase {
    func testOptionalShouldBeResolved_transient() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            context.register { "dependency" }
        }

        let value: String? = try container.resolve()
        XCTAssertNotNil(value)
    }

    func testOptionalShouldBeResolved_singleton() throws {
        let container = DependencyContainer { context in
            context.register { "dependency" }.asSingleton()
        }

        let value: String? = try container.resolve()
        let value2: String? = try container.resolve()
        XCTAssertNotNil(value)
        XCTAssertNotNil(value2)
    }
}
