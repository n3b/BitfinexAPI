import Foundation

public struct BookPrint: APIDataStructure {
    public let price: NSNumber
    public let amount: NSNumber
    public let count: Int
    
    init(_ data: [Any]) throws {
        if data.count < 3 {
            throw Basic.InvalidEntityStructure
        }
        
        guard let price = data[0] as? NSNumber,
            let count = data[1] as? Int,
            let amount = data[2] as? NSNumber
            else {
                throw Basic.InvalidEntityStructure
        }
        
        self.price = price
        self.amount = amount
        self.count = count
    }
}
