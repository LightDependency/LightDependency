@inline(__always)
func _do<Result>(_ action: () throws -> Result, finally: () -> ()) rethrows -> Result {
    defer { finally() }

    return try action()
}
