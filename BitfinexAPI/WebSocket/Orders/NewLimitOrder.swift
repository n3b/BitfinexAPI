import Foundation

public struct NewLimitOrder: NewOrder {
    public var gid: Int32?
    public var isHidden = false
    public var isExchange = true
    public var isFok = false
    public var isPostOnly = false
    
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
        if isFok {
            if isExchange {
                type = .ExFok
            } else {
                type = .Fok
            }
        } else {
            if isExchange {
                type = .ExLimit
            } else {
                type = .Limit
            }
        }
        
        var ret: [String: Any] = [
            "cid": cid,
            "symbol": symbol.symbol,
            "amount": formatPrice(amount),
            "type": type.rawValue,
            "price": formatPrice(price),
            "hidden": isHidden ? 1 : 0,
            "postonly": isPostOnly ? 1 : 0,
            ]
        if gid != nil {
            ret["gid"] = gid
        }
        return ret
    }
}
