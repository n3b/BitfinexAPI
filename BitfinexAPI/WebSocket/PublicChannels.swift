import Foundation
import Starscream

public class Channel: Hashable {

    var id: Int?

    public enum type: String {
        case trades
        case ticker
        case book
    }

    func handleRawData(_ data: [Any]) throws {
        switch data[1] {
            case let snapshot as [[Any]]:
                try handleSnapshot(snapshot)
            case let update as [Any]:
                try handleUpdate(update)
            case let name as String where name == "hb":
                handleHeartbeat()
            case let name as String where data.count > 2 && data[2] is [Any]:
                try handleNamedUpdate(name, data[2] as! [Any])
            default: throw Basic.WebSocket("Unknown data format")
        }
    }

    func handleHeartbeat() {
    }

    func handleUpdate(_ data: [Any]) throws {
    }

    func handleSnapshot(_ data: [[Any]]) throws {
    }

    func handleNamedUpdate(_ name: String, _ data: [Any]) throws {
    }

    func onError(_ error: Basic) {
    }

    public var hashValue: Int {
        return 0
    }

    public static func ==(lhs: Channel, rhs: Channel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public class TradesChannel: Channel, ChannelStringCommand {
    public let key: ChannelKey
    let subscriber: TradesSubscriber

    public init(_ symbol: Symbol, _ subscriber: TradesSubscriber) {
        key = ChannelKey(.trades, symbol)
        self.subscriber = subscriber
    }

    override func handleSnapshot(_ snapshot: [[Any]]) throws {
        let mapped = try snapshot.map {
            try TradePrint($0)
        }
        subscriber.onTradesSnapshot(mapped)
    }

    override func handleUpdate(_ data: [Any]) throws {
    }

    override func handleNamedUpdate(_ name: String, _ data: [Any]) throws {
        let tp = try TradePrint(data)
        switch name {
            case "te":
                subscriber.onTradeExecuted(tp)
            case "tu":
                subscriber.onTradeUpdated(tp)
            default: throw Basic.General("Unsupported trades data '\(name)'")
        }
    }

    override func onError(_ error: Basic) {
        subscriber.onError(error, self)
    }

    public override var hashValue: Int {
        return key.hashValue
    }
}

public class TickerChannel: Channel, ChannelStringCommand {
    public let key: ChannelKey
    let subscriber: TickerSubscriber

    public init(_ symbol: Symbol, _ subscriber: TickerSubscriber) {
        key = ChannelKey(.ticker, symbol)
        self.subscriber = subscriber
    }

    override func handleUpdate(_ data: [Any]) throws {
        let tp = try TickerPrint(data)
        subscriber.onTickerUpdate(tp, key.symbol)
    }

    public override var hashValue: Int {
        return key.hashValue
    }

    override func onError(_ error: Basic) {
        subscriber.onError(error, self)
    }
}

public class BookChannel: Channel, ChannelStringCommand {
    public let key: ChannelKey
    let subscriber: BookSubscriber
    var subscribeString: String {
        return "{\"event\":\"subscribe\", \"channel\":\"\(key.type)\",\"symbol\":\"\(key.symbol.symbol)\",\"prec\":\"\(precision)\",\"freq\":\"\(frequency)\",\"len\":\"\(length.rawValue)\"}"
    }

    public var precision: Precision = .P0
    public var frequency: Frequency = .F0
    public var length: Length = .L25

    public enum Precision: String {
        case P0, P1, P2, P3
    }

    public enum Frequency: String {
        case F0, F1
    }

    public enum Length: String {
        case L25 = "25"
        case L100 = "100"
    }

    public init(_ symbol: Symbol, _ subscriber: BookSubscriber) {
        key = ChannelKey(.book, symbol)
        self.subscriber = subscriber
    }

    override func handleSnapshot(_ snapshot: [[Any]]) throws {
        let mapped = try snapshot.map {
            try BookPrint($0)
        }
        subscriber.onBookSnapshot(mapped, key.symbol)
    }

    override func handleUpdate(_ data: [Any]) throws {
        let bp = try BookPrint(data)
        subscriber.onBookUpdate(bp, key.symbol)
    }

    public override var hashValue: Int {
        return key.hashValue
    }

    override func onError(_ error: Basic) {
        subscriber.onError(error, self)
    }
}

public protocol ChannelKeyCont {
    var key: ChannelKey { get }
}

protocol ChannelStringCommand: ChannelKeyCont {
    var subscribeString: String { get }
}

extension ChannelStringCommand {
    var subscribeString: String {
        return "{\"event\":\"subscribe\", \"channel\":\"\(key.type)\",\"symbol\":\"\(key.symbol.symbol)\"}"
    }
}

public struct ChannelKey: Hashable {
    public let symbol: Symbol
    public let type: Channel.type

    init(_ type: Channel.type, _ symbol: Symbol) {
        self.symbol = symbol
        self.type = type
    }

    public var hashValue: Int {
        return "\(type)\(symbol.value)".hashValue
    }

    public static func ==(lhs: ChannelKey, rhs: ChannelKey) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
