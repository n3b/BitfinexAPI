import Foundation

public struct WalletPrint: AuthPrint {
    public let wallet: type
    public let currency: String
    public let interest: NSNumber
    public let balance: NSNumber
    public let available: NSNumber?
    
    public enum type: String {
        case Exchange = "exchange"
        case Margin = "margin"
        case Funding = "funding"
        case Unknown
    }
    
    init(_ data: [Any]) throws {
        if data.count < 5 {
            throw Basic.InvalidEntityStructure
        }
        
        guard let wallet = data[0] as? String,
            let currency = data[1] as? String,
            let balance = data[2] as? NSNumber,
            let interest = data[3] as? NSNumber
            else {
                throw Basic.InvalidEntityStructure
        }
        
        self.wallet = type(rawValue: wallet) ?? .Unknown
        self.currency = currency
        self.balance = balance
        self.interest = interest
        self.available = data[4] as? NSNumber
    }
}
