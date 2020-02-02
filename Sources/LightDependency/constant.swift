@inlinable
func constant<TIn, TOut>(_ value: TOut) -> (TIn) -> TOut {
    return { _ in value }
}
