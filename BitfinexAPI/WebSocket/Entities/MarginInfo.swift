import Foundation

public struct MarginInfo: AuthPrint {
    public let balance: BaseBalance?
    public let symbol: SymbolBalance?
    
    public struct BaseBalance {
        public let pl: NSNumber
        public let swaps: NSNumber
        public let margin: NSNumber
        public let marginNet: NSNumber
    }
    
    public struct SymbolBalance {
        public let tradeable: NSNumber
        public let gross: NSNumber
        public let buy: NSNumber
        public let sell: NSNumber
        public let symbol: Symbol
    }
    
    init(_ data: [Any]) throws {
        if data.count < 2 {
            throw Basic.InvalidEntityStructure
        }
        
        guard let name = data[0] as? String,
            let sub = data[1] as? [Any],
            let s1 = sub[0] as? NSNumber,
            let s2 = sub[1] as? NSNumber,
            let s3 = sub[2] as? NSNumber,
            let s4 = sub[3] as? NSNumber
            else {
                throw Basic.InvalidEntityStructure
        }
        
        if name == "base" {
            balance = BaseBalance(pl: s1, swaps: s2, margin: s3, marginNet: s4)
            symbol = nil
        } else {
            guard let symbol = Symbol(name) else {
                throw Basic.InvalidEntityStructure
            }
            self.symbol = SymbolBalance(tradeable: s1, gross: s2, buy: s3, sell: s4, symbol: symbol)
            balance = nil
        }
    }
}
