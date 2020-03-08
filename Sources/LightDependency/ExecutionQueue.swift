final class ExecutionQueueInfo<Item> {
    let item: Item
    let parent: ExecutionQueueInfo?
    let enqueuedFromItem: ExecutionQueueInfo?

    init(item: Item, parent: ExecutionQueueInfo? = nil, enqueuedFromItem: ExecutionQueueInfo? = nil) {
        self.item = item
        self.parent = parent
        self.enqueuedFromItem = enqueuedFromItem
    }
}

final class ExecutionQueue<Item> {
    struct ExecutionItem {
        let info: ExecutionQueueInfo<Item>
        let action: (ExecutionQueue) throws -> Void
    }

    let info: ExecutionQueueInfo<Item>?
    private let stack: Stack<ExecutionItem>
    private let group: Int

    init() {
        info = nil
        stack = Stack()
        group = 0
    }

    private init(info: ExecutionQueueInfo<Item>, stack: Stack<ExecutionItem>, group: Int) {
        self.info = info
        self.stack = stack
        self.group = group
    }

    func sync<Result>(item: Item, _ action: (ExecutionQueue) throws -> Result) throws -> Result {
        let info = ExecutionQueueInfo(item: item, parent: self.info)
        let queue = ExecutionQueue(info: info, stack: stack, group: group)

        let result: Result!
        var errors: [Error] = []

        do {
            result = try action(queue)
        } catch {
            result = nil
            errors.append(error)
        }

        if self.info == nil {
            executeActionsFromStack(&errors)
        }

        switch errors.count {
        case 0:
            return result

        case 1:
            throw errors[0]

        default:
            throw AggregateError(errors: errors)
        }
    }

    func async(item: Item, _ action: @escaping (ExecutionQueue) throws -> Void) {
        let info = ExecutionQueueInfo(item: item, enqueuedFromItem: self.info)
        stack.push(value: .init(info: info, action: action), group: group)
    }

    private func executeActionsFromStack(_ errors: inout [Error]) {
        var group = self.group
        while let item = stack.pop() {
            group += 1
            let queue = ExecutionQueue(info: item.info, stack: stack, group: group)

            do {
                try item.action(queue)
            } catch {
                errors.append(error)
            }
        }
    }
}

typealias ResolutionQueueInfo = ExecutionQueueInfo<ResolvingStackItem>
typealias ResolutionQueue = ExecutionQueue<ResolvingStackItem>

private final class Stack<Value> {
    final class Item {
        let value: Value
        let group: Int
        var next: Item?

        init(value: Value, group: Int, next: Item?) {
            self.value = value
            self.group = group
            self.next = next
        }
    }

    private var topItem: Item?
    private var lastItemInGroup: Item?
    private var topGroup: Int?

    func push(value: Value, group: Int) {
        if topGroup == group, let lastItemInGroup = lastItemInGroup {
            let item = Item(value: value, group: group, next: lastItemInGroup.next)
            lastItemInGroup.next = item
            self.lastItemInGroup = item
        } else {
            topItem = Item(value: value, group: group, next: topItem)
            topGroup = group
            lastItemInGroup = topItem
        }
    }

    func pop() -> Value? {
        guard let item = topItem else { return nil }

        topItem = item.next

        if item === lastItemInGroup {
            lastItemInGroup = topItem
            topGroup = lastItemInGroup?.group
        }

        return item.value
    }
}
