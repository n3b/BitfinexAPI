import Foundation

public struct NewStopOrder: NewOrder {
    public var gid: Int32?
    public var isHidden = false
    public var isExchange = true
    public var isTrailing = false
    public var limitPrice: Double?
    
    let cid: Int32
    let symbol: Symbol
    let price: Double
    let amount: Double
    
    public init(_ symbol: Symbol, _ price: Double, _ amount: Double, _ cid: Int32) {
        self.symbol = symbol
        self.price = price
        self.amount = amount
        self.cid = cid
    }
    
    public var data: [String: Any?] {
        var type: OrderType
        if isExchange {
            type = .ExStop
            if limitPrice != nil {
                type = .ExStopLimit
            } else if isTrailing {
                type = .ExTrStop
            }
        } else {
            type = .Stop
            if limitPrice != nil {
                type = .StopLimit
            } else if isTrailing {
                type = .TrStop
            }
        }
        
        var ret: [String: Any] = [
            "cid": cid,
            "symbol": symbol.symbol,
            "amount": formatPrice(amount),
            "type": type.rawValue,
            "hidden": isHidden ? 1 : 0,
            ]
        if isTrailing {
            ret["price_trailing"] = formatPrice(price)
        } else {
            ret["price"] = formatPrice(price)
        }
        if limitPrice != nil {
            ret["price_aux_limit"] = formatPrice(limitPrice!)
        }
        if gid != nil {
            ret["gid"] = gid
        }
        return ret
    }
}
