final class UserError: Error, Equatable {
    let message: String

    init(message: String = "default message") {
        self.message = message
    }

    static func ==(lhs: UserError, rhs: UserError) -> Bool {
        return lhs.message == rhs.message
    }
}
