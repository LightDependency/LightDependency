import Foundation

struct Diagnostics {

    static func validateResolutionQueue(_ queueInfo: ResolutionQueueInfo?, _ debugInfo: DebugInfo) throws {
        guard let info = queueInfo else { return }

        let topItem = info.item

        let stack = sequence(first: info, next: { $0.parent }).map { $0.item }

        let isSetUp = stack.last?.setUpPlace != nil
        guard !isSetUp else { return }

        for parentItem in stack.dropFirst() {

            if topItem.dependencyKey == parentItem.dependencyKey
                && topItem.registrationOwnerContainer === parentItem.registrationOwnerContainer {

                throw DependencyResolutionError(
                    errorType: .recursiveDependencyFound,
                    dependencyType: topItem.dependencyKey.type,
                    dependencyName: topItem.dependencyKey.name,
                    resolvingStack: ResolvingStack(queueInfo: queueInfo),
                    file: debugInfo.file,
                    line: debugInfo.line
                )

            }
        }
    }

}
