import Foundation

public struct BalanceInfo: AuthPrint {
    public let aum: NSNumber
    public let aumNet: NSNumber
    
    init(_ data: [Any]) throws {
        if data.count < 2 {
            throw Basic.InvalidEntityStructure
        }
        
        guard let aum = data[0] as? NSNumber,
            let aumNet = data[1] as? NSNumber
            else {
                throw Basic.InvalidEntityStructure
        }
        
        self.aum = aum
        self.aumNet = aumNet
    }
}
