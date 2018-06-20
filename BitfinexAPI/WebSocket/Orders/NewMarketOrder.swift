import Foundation

public struct NewMarketOrder: NewOrder {
    public var gid: Int32?
    public var isExchange = true
    
    let cid: Int32
    let symbol: Symbol
    let amount: Double
    
    public init(_ symbol: Symbol, _ amount: Double, _ cid: Int32) {
        self.symbol = symbol
        self.amount = amount
        self.cid = cid
    }
    
    public var data: [String: Any?] {
        let type: OrderType = isExchange ? .ExMarket : .Market
        
        var ret: [String: Any] = [
            "cid": cid,
            "symbol": symbol.value,
            "amount": formatPrice(amount),
            "type": type.rawValue
        ]
        if gid != nil {
            ret["gid"] = gid
        }
        return ret
    }
}

