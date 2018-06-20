import Foundation

public struct OrderMultiOP {
    var ops: [Any] = []
    
    public init() {
    }
    
    public mutating func append(_ order: OrderInputData) throws {
        switch order {
        case is NewOrder, is CancelOrder, is CancelOrderMulti:
            ops.append(order.data)
        default: throw Basic.InvalidEntityStructure
        }
    }
    
    public var data: [Any?] {
        return [0, "ox_multi", nil, ops]
    }
}
