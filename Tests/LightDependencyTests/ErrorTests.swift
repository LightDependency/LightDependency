import XCTest
import LightDependency

final class ErrorTests: XCTestCase {
    var container: Container!

    override func setUp() {
        container = LightContainer.createRootContainer()
    }

    func testShouldThrowDependencyNotRegisteredError() {
        XCTAssertThrowsError(try container.resolve(file: "testFile", line: 33) as Int) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(DependencyResolutionError.ErrorType.dependencyNotRegistered, error.errorType)
            XCTAssertEqual("testFile", String(describing: error.file))
            XCTAssertEqual(33, error.line)
        }
    }

    func testShouldThrowRecursiveDependencyFoundError() {
        container.configure(defaults: .createNewInstancePerResolve) { context in
            context.initContext.register(ClassA.init)
            context.initContext.register(ClassB.init)
            context.initContext.register(ClassC.init)
        }

        XCTAssertThrowsError(try container.resolve() as ClassA) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(DependencyResolutionError.ErrorType.recursiveDependencyFound, error.errorType)
        }
    }

    func testShouldThrowUsingScopedContainerForRegistrationFromChildContainerError() throws {
        let parentContainer = try container.createChildContainer { context in
            context.name = "parent"
            context.scopes = ["parent-scope"]
        }

        let childContainer = try parentContainer.createChildContainer { context in
            context.name = "child"
            context.with(defaults: .createNewInstancePerScope("parent-scope"), { context in
                context.register { "dependency" }
            })
        }

        XCTAssertThrowsError(try childContainer.resolve() as String) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(DependencyResolutionError.ErrorType.usingScopedContainerForRegistrationFromChildContainer, error.errorType)
        }
    }

    func testShouldThrowScopeWasNotFoundUpToHierarchyError() throws {
        container.configure(defaults: .createNewInstancePerScope("my-scope")) { context in
            context.register { "dependency" }
        }

        let childContainer = try container.createChildContainer { context in
            context.name = "child"
            context.scopes = ["other-scope"]
        }

        XCTAssertThrowsError(try childContainer.resolve() as String) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(DependencyResolutionError.ErrorType.scopeWasNotFoundUpToHierarchy, error.errorType)
        }
    }

    func testShouldThrowTryingToResolveSingleDependencyWhenMultipleAreRegisteredError() throws {
        container.configure(defaults: .createNewInstancePerResolve) { context in
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
        container.configure(defaults: .createNewInstancePerResolve) { context in
            context.register { "dependency 1" }
            context.register { "dependency 2" }.withName("name")
        }

        XCTAssertNoThrow(try container.resolve() as String)
        XCTAssertNoThrow(try container.asResolver().resolve(byName: "name") as String)
    }

    func testShouldThrowIfSingletonInstanceFromParentDependsOnInstanceFromChildContainer() throws {
        container.configure(defaults: .registerSingletons) { context in
            context.initContext.register(LogService.init)
        }

        let childContainer = try container.createChildContainer { context in
            context.name = "child"
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.initContext.register(RealTimeService.init)
                    .asDependency(ofType: { $0 as TimeServiceType })
            })
        }

        XCTAssertThrowsError(try childContainer.resolve() as LogService) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(.resolvingIsForbiddenBecauseRequiresSavingInstanceWithDependencyFromChildContainer, error.errorType)
        }
    }

    func testShouldNotThrowIfPerContainerInstanceFromParentDependsOnInstanceFromChildContainer() throws {
        container.configure(defaults: .createNewInstancePerContainer) { context in
            context.initContext.register(LogService.init)
        }

        let childContainer = try container.createChildContainer { context in
            context.name = "child"
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.initContext.register(RealTimeService.init)
                    .asDependency(ofType: { $0 as TimeServiceType })
            })
        }

        XCTAssertNoThrow(try childContainer.resolve() as LogService)
    }

    func testShouldNotThrowIfPerResolveInstanceFromParentDependsOnInstanceFromChildContainer() throws {
        container.configure(defaults: .createNewInstancePerResolve) { context in
            context.initContext.register(LogService.init)
        }

        let childContainer = try container.createChildContainer { context in
            context.name = "child"
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.initContext.register(RealTimeService.init)
                    .asDependency(ofType: { $0 as TimeServiceType })
            })
        }

        XCTAssertNoThrow(try childContainer.resolve() as LogService)
    }

    func testShouldThrowIfScopedInstanceFromParentDependsOnInstanceFromChildContainer() throws {
        container.configure(defaults: .createNewInstancePerScope("scope")) { context in
            context.initContext.register(LogService.init)
        }

        let parentContainer = try container.createChildContainer { context in
            context.name = "parent"
            context.scopes = ["scope"]
        }

        let childContainer = try parentContainer.createChildContainer { context in
            context.name = "child"
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.initContext.register(RealTimeService.init)
                    .asDependency(ofType: { $0 as TimeServiceType })
            })
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
