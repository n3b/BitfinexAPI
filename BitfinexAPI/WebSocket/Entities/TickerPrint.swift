import Foundation

public struct TickerPrint: APIDataStructure {
    public let bid: NSNumber
    public let bidSize: NSNumber
    public let ask: NSNumber
    public let askSize: NSNumber
    public let change: NSNumber
    public let changePercent: NSNumber
    public let last: NSNumber
    public let volume: NSNumber
    public let high: NSNumber
    public let low: NSNumber
    
    init(_ data: [Any]) throws {
        if data.count < 10 {
            throw Basic.InvalidEntityStructure
        }
        
        guard let bid = data[0] as? NSNumber,
            let bidSize = data[1] as? NSNumber,
            let ask = data[2] as? NSNumber,
            let askSize = data[3] as? NSNumber,
            let change = data[4] as? NSNumber,
            let changePercent = data[5] as? NSNumber,
            let last = data[6] as? NSNumber,
            let volume = data[7] as? NSNumber,
            let high = data[8] as? NSNumber,
            let low = data[9] as? NSNumber
            else {
                throw Basic.InvalidEntityStructure
        }
        
        self.bid = bid
        self.bidSize = bidSize
        self.ask = ask
        self.askSize = askSize
        self.change = change
        self.changePercent = changePercent
        self.last = last
        self.volume = volume
        self.high = high
        self.low = low
    }
}
