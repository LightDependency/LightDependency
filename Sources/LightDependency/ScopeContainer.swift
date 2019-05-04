protocol ScopeContainer: class, Container {
    var parent: Self? { get }
    var scopes: Set<String> { get }
}

extension ScopeContainer {
    var hierarchy: UnfoldSequence<Self, (Self?, Bool)> {
        return sequence(first: self, next: { $0.parent })
    }
}
