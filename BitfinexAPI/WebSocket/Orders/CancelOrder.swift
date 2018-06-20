import Foundation

public enum CancelOrder: OrderInputData {
    
    case Id(UInt64)
    case Cid(Int32, Date)
    
    public var data: [String: Any?] {
        var ret: [String: Any] = [:]
        switch self {
        case let .Id(id):
            ret["id"] = id
        case let .Cid(сid, date):
            ret["cid"] = сid
            ret["cid_date"] = format(date)
        }
        return ret
    }
}

public protocol CancelOrderMulti: OrderInputData {
}

public struct CancelOrderMultiID: CancelOrderMulti {
    let orders: [UInt64]
    
    public var data: [String: Any?] {
        return ["id": orders]
    }
}

public struct CancelOrderMultiCID: CancelOrderMulti {
    let orders: [(Int32, Date)]
    
    public init(_ orders: [(Int32, Date)]) {
        self.orders = orders
    }
    
    public var data: [String: Any?] {
        return ["cid": orders.map {
            [$0.0, format($0.1)]
            }]
    }
}

public struct CancelOrderMultiGID: CancelOrderMulti {
    let orders: [(Int32, Int32?)]
    
    public init(_ orders: [(Int32, Int32?)]) {
        self.orders = orders
    }
    
    public var data: [String: Any?] {
        return ["gid": orders.map {
            $0.1 == nil ? [$0.0] : [$0.0, $0.1!]
            }]
    }
}

