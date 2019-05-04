import Foundation

protocol Service1Type {
    func service1Method()
}

protocol Service2Type {
    func service2Method()
}

protocol ServiceWithAssociatedType {
    associatedtype SomeType

    func serviceAssociatedTypeMethod()
}

final class SuperService {
}

extension SuperService: Service1Type {
    func service1Method() {
    }
}

extension SuperService: Service2Type {
    func service2Method() {
    }
}

extension SuperService: ServiceWithAssociatedType {
    typealias SomeType = String

    func serviceAssociatedTypeMethod() {
    }
}

final class AnyServiceWithAssociatedType<SomeType>: ServiceWithAssociatedType {
    private let _serviceAssociatedTypeMethod: () -> Void

    func serviceAssociatedTypeMethod() {
        _serviceAssociatedTypeMethod()
    }

    init<Service: ServiceWithAssociatedType>(_ service: Service) where Service.SomeType == SomeType {
        self._serviceAssociatedTypeMethod = service.serviceAssociatedTypeMethod
    }
}

final class LogService {
    let timeService: TimeServiceType

    init(timeService: TimeServiceType) {
        self.timeService = timeService
    }
}

protocol TimeServiceType {
    var now: Date { get }
}

final class RealTimeService: TimeServiceType {
    var now: Date {
        return Date()
    }
}

struct MockTimeService: TimeServiceType {
    let now: Date
}
