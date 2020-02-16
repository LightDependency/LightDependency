import XCTest
import LightDependency

final class ErrorTests: XCTestCase {

    func testShouldThrowDependencyNotRegisteredError() {
        let container = DependencyContainer { _ in }
        XCTAssertThrowsError(try container.resolve(file: "testFile", line: 33) as Int) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(DependencyResolutionError.ErrorType.dependencyNotRegistered, error.errorType)
            XCTAssertEqual("testFile", String(describing: error.file))
            XCTAssertEqual(33, error.line)
        }
    }

    func testShouldThrowRecursiveDependencyFoundError() {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            context.register(ClassA.init)
            context.register(ClassB.init)
            context.register(ClassC.init)
        }

        XCTAssertThrowsError(try container.resolve() as ClassA) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(DependencyResolutionError.ErrorType.recursiveDependencyFound, error.errorType)
        }
    }

    func testShouldThrowUsingScopedContainerForRegistrationFromChildContainerError() throws {
        let container = DependencyContainer { _ in }
        let parentContainer = container.createChildContainer(name: "parent", scopes: ["parent-scope"])

        let childContainer = parentContainer.createChildContainer(name: "child") { context in
            context.with(lifestyle: .scoped("parent-scope")) { context in
                context.register { "dependency" }
            }
        }

        XCTAssertThrowsError(try childContainer.resolve() as String) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(DependencyResolutionError.ErrorType.usingScopedContainerForRegistrationFromChildContainer, error.errorType)
        }
    }

    func testShouldThrowScopeWasNotFoundUpToHierarchyError() throws {
        let container = DependencyContainer(defaultLifestyle: .scoped("my-scope")) { context in
            context.register { "dependency" }
        }

        let childContainer = container.createChildContainer(name: "child", scopes: ["other-scope"])

        XCTAssertThrowsError(try childContainer.resolve() as String) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(DependencyResolutionError.ErrorType.scopeWasNotFoundUpToHierarchy, error.errorType)
        }
    }

    func testShouldThrowTryingToResolveSingleDependencyWhenMultipleAreRegisteredError() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            context.register { "dependency 1" }
            context.register { "dependency 2" }
        }

        XCTAssertThrowsError(try container.resolve() as String) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(DependencyResolutionError.ErrorType.tryingToResolveSingleDependencyWhenMultipleAreRegistered, error.errorType)
        }
    }

    func testShouldNotThrowTryingToResolveSingleDependencyWhenMultipleAreRegisteredErrorWhenDependencyIsNamed() {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            context.register { "dependency 1" }
            context.register { "dependency 2" }.withName("name")
        }

        XCTAssertNoThrow(try container.resolve() as String)
        XCTAssertNoThrow(try container.asResolver().resolve(byName: "name") as String)
    }

    func testShouldThrowIfSingletonInstanceFromParentDependsOnInstanceFromChildContainer() throws {
        let container = DependencyContainer(defaultLifestyle: .singleton) { context in
            context.register(LogService.init)
        }

        let childContainer = container.createChildContainer(name: "child") { context in
            context.with(lifestyle: .transient) { context in
                context.register(RealTimeService.init)
                    .asDependency(ofType: { $0 as TimeServiceType })
            }
        }

        XCTAssertThrowsError(try childContainer.resolve() as LogService) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(.resolvingIsForbiddenBecauseRequiresSavingInstanceWithDependencyFromChildContainer, error.errorType)
        }
    }

    func testShouldNotThrowIfPerContainerInstanceFromParentDependsOnInstanceFromChildContainer() throws {
        let container = DependencyContainer(defaultLifestyle: .container) { context in
            context.register(LogService.init)
        }

        let childContainer = container.createChildContainer(name: "child") { context in
            context.with(lifestyle: .transient) { context in
                context.register(RealTimeService.init)
                    .asDependency(ofType: { $0 as TimeServiceType })
            }
        }

        XCTAssertNoThrow(try childContainer.resolve() as LogService)
    }

    func testShouldNotThrowIfPerResolveInstanceFromParentDependsOnInstanceFromChildContainer() throws {
        let container = DependencyContainer(defaultLifestyle: .transient) { context in
            context.register(LogService.init)
        }

        let childContainer = container.createChildContainer(name: "child") { context in
            context.with(lifestyle: .transient) { context in
                context.register(RealTimeService.init)
                    .asDependency(ofType: { $0 as TimeServiceType })
            }
        }

        XCTAssertNoThrow(try childContainer.resolve() as LogService)
    }

    func testShouldThrowIfScopedInstanceFromParentDependsOnInstanceFromChildContainer() throws {
        let container = DependencyContainer(defaultLifestyle: .scoped("scope")) { context in
            context.register(LogService.init)
        }

        let parentContainer = container.createChildContainer(name: "parent", scopes: ["scope"])

        let childContainer = parentContainer.createChildContainer(name: "child") { context in
            context.with(lifestyle: .transient) { context in
                context.register(RealTimeService.init)
                    .asDependency(ofType: { $0 as TimeServiceType })
            }
        }

        XCTAssertThrowsError(try childContainer.resolve() as LogService) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(.resolvingIsForbiddenBecauseRequiresSavingInstanceWithDependencyFromChildContainer, error.errorType)
        }
    }
}

private final class ClassA {
    init(_ value: ClassB) {
    }
}

private final class ClassB {
    init(_ value: ClassC) {
    }
}

private final class ClassC {
    init(_ value: ClassA) {
    }
}
