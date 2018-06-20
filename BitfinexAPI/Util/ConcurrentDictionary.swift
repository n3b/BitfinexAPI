import Foundation

public class ConcurrentDictionary<T: Hashable, V>: Sequence {

    public typealias DType = [T: V]
    public typealias Index = DType.Index

    let queue: DispatchQueue
    var c: DType

    public init(items: DType = DType()) {
        c = items
        queue = DispatchQueue(label: "tools.n3b.concurrentDictionary", qos: .default, attributes: .concurrent)
    }

    public var count: Int {
        var value = 0
        queue.sync {
            value = self.c.count
        }
        return value
    }

    public var startIndex: ConcurrentDictionary.Index {
        var value: ConcurrentDictionary.Index?
        queue.sync {
            value = self.c.startIndex
        }
        return value!
    }

    public var keys: Dictionary<T, V>.Keys {
        var value: Dictionary<T, V>.Keys?
        queue.sync {
            value = self.c.keys
        }
        return value!
    }

    public var values: [V] {
        var value: [V]?
        queue.sync {
            value = Array(self.c.values)
        }
        return value!
    }

    public subscript(key: T) -> V? {
        get {
            var value: V?
            queue.sync {
                value = self.c[key]
            }
            return value
        }
        set {
            queue.async(flags: .barrier) {
                self.c[key] = newValue
            }
        }
    }

    public func removeAll() {
        queue.async(flags: .barrier) {
            self.c.removeAll()
        }
    }

    public func makeIterator() -> ConcurrentDictionaryIterator<T, V> {
        var value: ConcurrentDictionaryIterator<T, V>?
        queue.sync {
            value = ConcurrentDictionaryIterator<T, V>(Array(self.c.keys), Array(self.c.values))
        }
        return value!
    }

    public func intIndex(forKey: T) -> Int? {
        var value: Int?
        queue.sync {
            if let idx = self.c.index(forKey: forKey) {
                value = self.c.distance(from: self.c.startIndex, to: idx)
            }
        }
        return value!
    }

    public func value(at: Int) -> (key: T, value: V)? {
        var value: (key: T, value: V)?
        queue.sync {
            value = self.c[self.c.index(self.c.startIndex, offsetBy: at)]
        }
        return value!
    }
}

public struct ConcurrentDictionaryIterator<T, V>: IteratorProtocol {
    let keys: [T]
    let values: [V]
    var idx = 0

    public init(_ keys: [T], _ values: [V]) {
        self.keys = keys
        self.values = values
    }

    public mutating func next() -> (T, V)? {
        if idx == values.count {
            return nil
        }
        defer {
            idx += 1
        }
        return (keys[idx], values[idx])
    }
}
