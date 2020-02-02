import XCTest
import LightDependency

final class ResolveOptionalsTests: XCTestCase {
    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    func testOptionalShouldBeResolved() throws {
        container.configure(defaults: .createNewInstancePerResolve) { container in
            container.register { "dependency" }
        }

        let value: String? = try container.resolve()
        XCTAssertEqual("dependency", value)
    }
}
