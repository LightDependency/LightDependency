import XCTest
import LightDependency

final class ResolveOptionalsTests: XCTestCase {
    func testOptionalShouldBeResolved() throws {
        let container = DependencyContainer(defaults: .createNewInstancePerResolve) { container in
            container.register { "dependency" }
        }

        let value: String? = try container.resolve()
        XCTAssertEqual("dependency", value)
    }
}
