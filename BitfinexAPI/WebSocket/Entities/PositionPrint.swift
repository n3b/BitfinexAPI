import Foundation

public struct PositionPrint: AuthPrint {
    public let symbol: Symbol
    public let status: String
    public let amount: NSNumber
    public let price: NSNumber
    public let funding: NSNumber
    public let isFundingDaily: Bool
    public let pl: NSNumber
    public let plPerc: NSNumber
    public let priceLiq: NSNumber?
    public let leverage: NSNumber
    
    init(_ data: [Any]) throws {
        if data.count < 10 {
            throw Basic.InvalidEntityStructure
        }
        
        guard let symbol = Symbol(data[0] as? String ?? ""),
            let status = data[1] as? String,
            let amount = data[2] as? NSNumber,
            let price = data[3] as? NSNumber,
            let funding = data[4] as? NSNumber,
            let isFundingDaily = data[5] as? Bool,
            let pl = data[6] as? NSNumber,
            let plPerc = data[7] as? NSNumber,
            let leverage = data[9] as? NSNumber
            else {
                throw Basic.InvalidEntityStructure
        }
        
        self.symbol = symbol
        self.status = status
        self.amount = amount
        self.price = price
        self.funding = funding
        self.isFundingDaily = !isFundingDaily
        self.pl = pl
        self.plPerc = plPerc
        self.leverage = leverage
        
        priceLiq = data[8] as? NSNumber
    }
}
