import Foundation

class Queue<T> {

    var count = 0

    class Node {
        let value: T
        var next: Node?
        weak var previous: Node?

        init(value: T) {
            self.value = value
        }
    }

    var head: Node?
    var tail: Node?

    var isEmpty: Bool {
        return head == nil
    }

    func enqueue(value: T) {

        let newNode = Node(value: value)
        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
        count += 1
    }

    func dequeue() -> T? {
        let headNode = head
        if headNode != nil {
            head = headNode?.next
            headNode?.next?.previous = nil
            headNode?.next = nil
            if head == nil {
                tail = nil
            }
            count -= 1
        }
        return headNode?.value
    }

    public func each(_ cb: (T) -> Void) {
        var node = head

        while node != nil {
            cb(node!.value)
            node = node!.next
        }
    }

    public func removeAll() {
        head = nil
        tail = nil
    }
}
