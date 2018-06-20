import Foundation

public struct TradePrint: APIDataStructure {
    public let price: NSNumber
    public let amount: NSNumber
    public let date: Date
    
    init(_ data: [Any]) throws {
        if data.count < 4 {
            throw Basic.InvalidEntityStructure
        }
        
        guard let price = data[3] as? NSNumber,
            let amount = data[2] as? NSNumber,
            let date = data[1] as? Double
            else {
                throw Basic.InvalidEntityStructure
        }
        self.price = price
        self.amount = amount
        self.date = Date(timeIntervalSince1970: date / 1_000)
    }
}
