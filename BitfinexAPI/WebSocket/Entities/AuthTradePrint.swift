import Foundation

public struct AuthTradePrint: AuthPrint {
    public struct Order {
        public let id: Int
        public let type: String
        public let price: NSNumber
    }
    
    public let id: Int
    public let symbol: Symbol
    public let created: Date
    public let amount: NSNumber
    public let price: NSNumber
    public let isMaker: Bool
    public let order: Order
    public let fee: NSNumber?
    public let feeCurrency: String?
    
    
    init(_ data: [Any]) throws {
        if data.count < 9 {
            throw Basic.InvalidEntityStructure
        }
        
        guard let id = data[0] as? Int,
            let symbol = Symbol(data[1] as? String ?? ""),
            let created = data[2] as? Double,
            let amount = data[4] as? NSNumber,
            let price = data[5] as? NSNumber,
            let isMaker = data[8] as? Bool,
            let orderId = data[3] as? Int,
            let orderType = data[6] as? String,
            let orderPrice = data[7] as? NSNumber
            else {
                throw Basic.InvalidEntityStructure
        }
        
        self.id = id
        self.symbol = symbol
        self.created = Date(timeIntervalSince1970: created / 1_000)
        self.amount = amount
        self.price = price
        self.isMaker = isMaker
        self.order = Order(id: orderId, type: orderType, price: orderPrice)
        
        fee = data.count >= 11 ? data[9] as? NSNumber : nil
        feeCurrency = data.count >= 11 ? data[10] as? String : nil
    }
}
