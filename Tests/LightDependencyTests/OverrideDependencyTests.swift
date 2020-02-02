import XCTest
import LightDependency

final class OverrideDependencyTests: XCTestCase {
    private let mockDate = Date(timeIntervalSinceReferenceDate: 1111)
    var container: DependencyContainer!

    override func setUp() {
        container = DependencyContainer()
    }

    func testNoNamedPerResolveDependencyShouldBeOverriddenByChildContainer() throws {
        container.configure(defaults: .createNewInstancePerResolve) { context in
            context.register { "from root" }
        }

        let childContainer = container.createChildContainer { context in
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.register { "from child" }
            })
        }

        let childChildContainer = childContainer.createChildContainer()

        XCTAssertEqual("from root", try container.resolve())
        XCTAssertEqual("from child", try childContainer.resolve())
        XCTAssertEqual("from child", try childChildContainer.resolve())
    }

    func testNamedPerResolveDependencyShouldBeOverriddenByChildContainer() throws {
        container.configure(defaults: .createNewInstancePerResolve) { context in
            context.register { "from root" }.withName("dep")
        }

        let childContainer = container.createChildContainer { context in
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.register { "from child" }.withName("dep")
            })
        }

        let childChildContainer = childContainer.createChildContainer()

        XCTAssertEqual("from root", try container.asResolver().resolve(byName: "dep"))
        XCTAssertEqual("from child", try childContainer.asResolver().resolve(byName: "dep"))
        XCTAssertEqual("from child", try childChildContainer.asResolver().resolve(byName: "dep"))
    }

    func testNoNamedSingletonDependencyShouldBeOverriddenByChildContainer() throws {
        container.configure(defaults: .registerSingletons) { context in
            context.register { "from root" }
        }

        let childContainer = container.createChildContainer { context in
            context.with(defaults: .registerSingletons, { context in
                context.register { "from child" }
            })
        }

        let childChildContainer = childContainer.createChildContainer()

        XCTAssertEqual("from root", try container.resolve())
        XCTAssertEqual("from child", try childContainer.resolve())
        XCTAssertEqual("from child", try childChildContainer.resolve())
    }

    func testNamedSingletonDependencyShouldBeOverriddenByChildContainer() throws {
        container.configure(defaults: .registerSingletons) { context in
            context.register { "from root" }.withName("dep")
        }

        let childContainer = container.createChildContainer { context in
            context.with(defaults: .registerSingletons, { context in
                context.register { "from child" }.withName("dep")
            })
        }

        let childChildContainer = childContainer.createChildContainer()

        XCTAssertEqual("from root", try container.asResolver().resolve(byName: "dep"))
        XCTAssertEqual("from child", try childContainer.asResolver().resolve(byName: "dep"))
        XCTAssertEqual("from child", try childChildContainer.asResolver().resolve(byName: "dep"))
    }

    func testNoNamedPerContainerDependencyShouldBeOverriddenByChildContainer() throws {
        container.configure(defaults: .createNewInstancePerContainer) { context in
            context.register { "from root" }
        }

        let childContainer = container.createChildContainer { context in
            context.with(defaults: .createNewInstancePerContainer, { context in
                context.register { "from child" }
            })
        }

        let childChildContainer = childContainer.createChildContainer()

        XCTAssertEqual("from root", try container.resolve())
        XCTAssertEqual("from child", try childContainer.resolve())
        XCTAssertEqual("from child", try childChildContainer.resolve())
    }

    func testNamedPerContainerDependencyShouldBeOverriddenByChildContainer() throws {
        container.configure(defaults: .createNewInstancePerContainer) { context in
            context.register { "from root" }.withName("dep")
        }

        let childContainer = container.createChildContainer { context in
            context.with(defaults: .createNewInstancePerContainer, { context in
                context.register { "from child" }.withName("dep")
            })
        }

        let childChildContainer = childContainer.createChildContainer()

        XCTAssertEqual("from root", try container.asResolver().resolve(byName: "dep"))
        XCTAssertEqual("from child", try childContainer.asResolver().resolve(byName: "dep"))
        XCTAssertEqual("from child", try childChildContainer.asResolver().resolve(byName: "dep"))
    }

    func testNoNamedPerScopeDependencyShouldBeOverriddenByChildContainer() throws {
        container.configure(defaults: .createNewInstancePerScope("scope")) { context in
            context.register { "from root" }
        }

        let parentContainer = container.createChildContainer(scopes: ["scope"])

        let childContainer = parentContainer.createChildContainer(scopes: ["scope"]) { context in
            context.with(defaults: .createNewInstancePerScope("scope"), { context in
                context.register { "from child" }
            })
        }

        let childChildContainer = childContainer.createChildContainer()

        XCTAssertEqual("from root", try parentContainer.resolve())
        XCTAssertEqual("from child", try childContainer.resolve())
        XCTAssertEqual("from child", try childChildContainer.resolve())
    }

    func testNamedPerScopeDependencyShouldBeOverriddenByChildContainer() throws {
        container.configure(defaults: .createNewInstancePerScope("scope")) { context in
            context.register { "from root" }.withName("dep")
        }

        let parentContainer = container.createChildContainer(scopes: ["scope"])

        let childContainer = parentContainer.createChildContainer(scopes: ["scope"]) { context in
            context.with(defaults: .createNewInstancePerScope("scope"), { context in
                context.register { "from child" }.withName("dep")
            })
        }

        let childChildContainer = childContainer.createChildContainer()

        XCTAssertEqual("from root", try parentContainer.asResolver().resolve(byName: "dep"))
        XCTAssertEqual("from child", try childContainer.asResolver().resolve(byName: "dep"))
        XCTAssertEqual("from child", try childChildContainer.asResolver().resolve(byName: "dep"))
    }

    func testNamedDependencyShouldBeOverriddenForResolvingMultipleNamedDependencies() throws {
        container.configure(defaults: .createNewInstancePerResolve) { context in
            context.register { "red" }.withName("fill")
            context.register { "blue" }.withName("text")
        }

        let childContainer = container.createChildContainer { context in
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.register { "white" }.withName("fill")
                context.register { "pink" }.withName("stroke")
            })
        }

        let expectedResultForRoot: [String: String] = [
            "fill": "red",
            "text": "blue"
        ]

        let expectedResultForChildContainerHierarchy: [String: String] = [
            "fill": "white",
            "text": "blue",
            "stroke": "pink"
        ]

        let expectedResultForChildContainer: [String: String] = [
            "fill": "white",
            "stroke": "pink"
        ]

        XCTAssertEqual(expectedResultForRoot, try container.asResolver().resolveNamed(from: .containerHierarchy))
        XCTAssertEqual(expectedResultForRoot, try container.asResolver().resolveNamed(from: .nearestContainer))
        XCTAssertEqual(expectedResultForChildContainerHierarchy, try childContainer.asResolver().resolveNamed(from: .containerHierarchy))
        XCTAssertEqual(expectedResultForChildContainer, try childContainer.asResolver().resolveNamed(from: .nearestContainer))
    }

    func testNamedDependencyShouldBeOverriddenForResolvingMultipleDependencies() throws {
        container.configure(defaults: .createNewInstancePerResolve) { context in
            context.register { "root-noname" }
            context.register { "red" }.withName("fill")
            context.register { "blue" }.withName("text")
        }

        let childContainer = container.createChildContainer { context in
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.register { "child-noname" }
                context.register { "white" }.withName("fill")
                context.register { "pink" }.withName("stroke")
            })
        }

        let expectedResultForRoot: Set<String> = ["root-noname", "red", "blue"]

        let expectedResultForChildContainerHierarchy: Set<String> = ["root-noname", "white", "blue", "child-noname", "pink"]

        let expectedResultForChildContainer: Set<String> = ["child-noname", "white", "pink"]

        XCTAssertEqual(expectedResultForRoot, Set(try container.asResolver().resolveAll(from: .containerHierarchy)))
        XCTAssertEqual(expectedResultForRoot, Set(try container.asResolver().resolveAll(from: .nearestContainer)))
        XCTAssertEqual(expectedResultForChildContainerHierarchy, Set(try childContainer.asResolver().resolveAll(from: .containerHierarchy)))
        XCTAssertEqual(expectedResultForChildContainer, Set(try childContainer.asResolver().resolveAll(from: .nearestContainer)))
    }

    func testChildContainerCanOverrideDependencyOfPerResolveInstanceFromParentContainer() throws {
        container.configure(defaults: .createNewInstancePerResolve) { context in
            context.register(LogService.init)
            context.register(RealTimeService.init)
                .asDependency(ofType: { $0 as TimeServiceType })
                .perResolve()
        }

        let childContainer = container.createChildContainer(name: "child") { context in
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.register { MockTimeService(now: self.mockDate) }
                    .asDependency(ofType: { $0 as TimeServiceType })
            })
        }

        let logServiceFromRoot: LogService = try container.resolve()
        let logServiceFromChild: LogService = try childContainer.resolve()

        XCTAssertTrue(logServiceFromRoot.timeService is RealTimeService)
        XCTAssertTrue(logServiceFromChild.timeService is MockTimeService)
    }

    func testChildContainerCanOverrideDependencyOfPerContainerInstanceFromParentContainer() throws {
        container.configure(defaults: .createNewInstancePerContainer) { context in
            context.register(LogService.init)
            context.register(RealTimeService.init)
                .asDependency(ofType: { $0 as TimeServiceType })
                .perResolve()
        }

        let childContainer = container.createChildContainer(name: "child") { context in
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.register { MockTimeService(now: self.mockDate) }
                    .asDependency(ofType: { $0 as TimeServiceType })
            })
        }

        let logServiceFromRoot: LogService = try container.resolve()
        let logServiceFromChild: LogService = try childContainer.resolve()

        XCTAssertTrue(logServiceFromRoot.timeService is RealTimeService)
        XCTAssertTrue(logServiceFromChild.timeService is MockTimeService)
    }

    func testChildContainerCanNotOverrideDependencyOfSingletonInstanceFromParentContainer() throws {
        container.configure(defaults: .registerSingletons) { context in
            context.register(LogService.init)
            context.register(RealTimeService.init)
                .asDependency(ofType: { $0 as TimeServiceType })
                .perResolve()
        }

        let childContainer = container.createChildContainer(name: "child") { context in
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.register { MockTimeService(now: self.mockDate) }
                    .asDependency(ofType: { $0 as TimeServiceType })
            })
        }

        let logServiceFromChild: LogService = try childContainer.resolve()
        let logServiceFromRoot: LogService = try container.resolve()

        XCTAssertTrue(logServiceFromRoot.timeService is RealTimeService)
        XCTAssertTrue(logServiceFromChild.timeService is RealTimeService)
    }

    func testChildContainerCanNotOverrideDependencyOfScopedInstanceFromParentContainer() throws {
        container.configure(defaults: .createNewInstancePerScope("scope")) { context in
            context.register(LogService.init)
            context.register(RealTimeService.init)
                .asDependency(ofType: { $0 as TimeServiceType })
                .perResolve()
        }

        let parentContainer = container.createChildContainer(name: "parent", scopes: ["scope"])

        let childContainer = parentContainer.createChildContainer(name: "child") { context in
            context.with(defaults: .createNewInstancePerResolve, { context in
                context.register { MockTimeService(now: self.mockDate) }
                    .asDependency(ofType: { $0 as TimeServiceType })
            })
        }

        let logServiceFromChild: LogService = try childContainer.resolve()
        let logServiceFromParent: LogService = try parentContainer.resolve()

        XCTAssertTrue(logServiceFromParent.timeService is RealTimeService)
        XCTAssertTrue(logServiceFromChild.timeService is RealTimeService)
        XCTAssertThrowsError(try container.resolve() as LogService) { error in
            XCTAssertTrue(error is DependencyResolutionError)
            let error = error as! DependencyResolutionError
            XCTAssertEqual(.scopeWasNotFoundUpToHierarchy, error.errorType)
        }
    }
}
