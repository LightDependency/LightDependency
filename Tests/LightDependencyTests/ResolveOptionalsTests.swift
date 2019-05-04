import XCTest
import LightDependency

final class ResolveOptionalsTests: XCTestCase {
    var container: Container!

    override func setUp() {
        container = LightContainer.createRootContainer()
    }

    func testOptionalShouldBeResolved() throws {
        container.configure(defaults: .createNewInstancePerResolve) { container in
            container.register { "dependency" }
        }

        let value: String? = try container.resolve()
        XCTAssertEqual("dependency", value)
    }
}
