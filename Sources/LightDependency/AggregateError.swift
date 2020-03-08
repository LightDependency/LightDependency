public struct AggregateError: Error {
    public let errors: [Error]

    public init(errors: [Error]) {
        self.errors = errors.flatMap { error -> [Error] in
            if let aggregateError = error as? AggregateError {
                return aggregateError.errors
            }

            return [error]
        }
    }
}
