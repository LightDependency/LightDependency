public struct RegistrationDefaults {
    public var instanceLifestyle: InstanceLifestyle

    public init(instanceLifestyle: InstanceLifestyle) {
        self.instanceLifestyle = instanceLifestyle
    }

    public static var registerSingletons: RegistrationDefaults {
        return RegistrationDefaults(instanceLifestyle: .singleton)
    }

    public static var createNewInstancePerResolve: RegistrationDefaults {
        return RegistrationDefaults(instanceLifestyle: .perResolve)
    }

    public static var createNewInstancePerContainer: RegistrationDefaults {
        return RegistrationDefaults(instanceLifestyle: .perContainer)
    }

    public static func createNewInstancePerScope(_ scopeName: String) -> RegistrationDefaults {
        return RegistrationDefaults(instanceLifestyle: .namedScope(scopeName))
    }

    public static var `default`: RegistrationDefaults {
        createNewInstancePerResolve
    }
}
