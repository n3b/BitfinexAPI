import Foundation

public struct OrderPrint: AuthPrint {
    public let id: UInt64
    public let gid: Int?
    public let cid: Int
    public let symbol: Symbol
    public let created: Date
    public let updated: Date
    public let amount: NSNumber
    public let amountOriginal: NSNumber
    public let type: OrderType
    public let flags: Int
    public let status: Status
    public let price: NSNumber
    public let priceAverage: NSNumber?
    public let priceTrailing: NSNumber?
    public let priceAuxLimit: NSNumber?
    public let notify: Bool
    public let hidden: Bool
    public let placedId: Int
    
    public enum Status: String {
        case Active = "ACTIVE"
        case Executed = "EXECUTED"
        case ParitallyFilled = "PARTIALLY FILLED"
        case Canceled = "CANCELED"
        case Unknown
    }
    
    public init(_ data: [Any]) throws {
        if data.count < 26 {
            throw Basic.InvalidEntityStructure
        }
        
        guard let id = data[0] as? UInt64,
            let cid = data[2] as? Int,
            let symbol = Symbol(data[3] as? String ?? ""),
            let created = data[4] as? Double,
            let updated = data[5] as? Double,
            let amount = data[6] as? NSNumber,
            let amountOriginal = data[7] as? NSNumber,
            let type = data[8] as? String,
            let orderType = OrderType(rawValue: type),
            let flags = data[12] as? Int,
            let status = data[13] as? String,
            let price = data[16] as? NSNumber,
            let notify = data[23] as? Bool,
            let hidden = data[24] as? Bool,
            let placedId = data[25] as? Int
            else {
                throw Basic.InvalidEntityStructure
        }
        
        self.id = id
        self.cid = cid
        self.symbol = symbol
        self.created = Date(timeIntervalSince1970: created)
        self.updated = Date(timeIntervalSince1970: updated)
        self.amount = amount
        self.amountOriginal = amountOriginal
        self.type = orderType
        self.flags = flags
        self.status = Status(rawValue: status) ?? .Unknown
        self.price = price
        self.notify = notify
        self.hidden = hidden
        self.placedId = placedId
        
        gid = data[1] as? Int
        priceAverage = data[17] as? NSNumber
        priceTrailing = data[18] as? NSNumber
        priceAuxLimit = data[19] as? NSNumber
    }
}

