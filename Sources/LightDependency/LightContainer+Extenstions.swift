import Foundation

private let PARENT_CONTAINER_NAME = "PARENT_CONTAINER_NAME"

extension LightContainer {
    public typealias ChildContainerFactory = (ChildContainerContext) -> Container

    public static func createRootContainer() -> LightContainer {
        let container = LightContainer(parent: nil, name: "root", scopes: [])
        container.configure(defaults: .createNewInstancePerResolve) { context in
            context.register(constant(Void()))

            context.register { resolver -> Container in
                let internalResolver = resolver as! LightResolver
                let parentContainer = internalResolver.resolvingContainer
                let containerName = generateContainerName(internalResolver)

                let childContainer = LightContainer(parent: parentContainer, name: containerName, scopes: [])
                return childContainer
            }

            context.register { resolver -> ChildContainerFactory in
                let internalResolver = resolver as! LightResolver
                let parentContainer = internalResolver.resolvingContainer

                let factory: ChildContainerFactory = { childContainerContext in
                    let containerName = childContainerContext.name ?? generateContainerName(internalResolver)
                    let lightContainerContext = LightContainerRegistrationContext()
                    childContainerContext.apply(to: lightContainerContext)
                    let childContainer = LightContainer(
                        parent: parentContainer,
                        name: containerName,
                        scopes: childContainerContext.scopes,
                        registrationContext: lightContainerContext)

                    return childContainer
                }

                return factory
            }

            context
                .register { resolver -> Container in
                    let internalResolver = resolver as! LightResolver
                    let parentContainer = internalResolver.resolvingContainer
                    return parentContainer
                }
                .withName(PARENT_CONTAINER_NAME)
        }

        return container
    }
}

private func generateContainerName(_ resolver: LightResolver) -> String {
    let id = UUID().uuidString
    if let lastItem = resolver.resolvingStack.stack.last {
        let place = " (\(lastItem.resolutionPlace.description))"
        return id + place
    }
    
    return id
}

extension Resolver {
    public func resolveParentContainer(file: StaticString = #file, line: UInt = #line) throws -> Container {
        return try resolve(byName: PARENT_CONTAINER_NAME, file: file, line: line)
    }

    public func createChildContainer(file: StaticString = #file, line: UInt = #line) throws -> Container {
        return try resolve(file: file, line: line)
    }

    public func createChildContainer(
        file: StaticString = #file,
        line: UInt = #line,
        _ configure: (ChildContainerContext) throws -> Void)
        throws -> Container {
            let context = ChildContainerContext()
            try configure(context)
            let factory: LightContainer.ChildContainerFactory = try resolve(file: file, line: line)
            return factory(context)
    }
}

extension Container {
    public func createChildContainer(file: StaticString = #file, line: UInt = #line) throws -> Container {
        return try resolve { resolver in try resolver.createChildContainer(file: file, line: line) }
    }

    public func createChildContainer(
        file: StaticString = #file,
        line: UInt = #line,
        _ configure: (ChildContainerContext) throws -> Void)
        throws -> Container {
            return try resolve { resolver in
                try resolver.createChildContainer(file: file, line: line, configure)
            }
    }
}
