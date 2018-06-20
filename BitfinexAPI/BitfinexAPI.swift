import Foundation

public protocol APIError: Error {
}

public enum Basic: APIError {
    case General(String)
    case WebSocket(String)
    case WebSocketBF(String, Int)
    case InvalidEntityStructure
}

public class BitfinexAPI {
    let c: Client

    public var isAuthenticated: Bool {
        return c.isAuthenticated
    }

    public var isConnected: Bool {
            return c.socket.isConnected
    }

    public var errorHandler: ApiErrorHandler? {
        get {
            return c.errorHandler
        }
        set {
            c.errorHandler = newValue
        }
    }

    public var authSubscriber: AuthSubscriber? {
        get {
            return c.authSubscriber
        }
        set {
            c.authSubscriber = newValue
        }
    }

    public var systemSubscriber: SystemSubscriber? {
        get {
            return c.subscriber
        }
        set {
            c.subscriber = newValue
        }
    }

    public init(_ url: String) {
        c = Client(url)
    }

    public func connect() {
        c.connect()
    }

    public func disconnect() {
        c.disconnect()
    }

    public func authenticate(_ key: String, _ secret: String, _ subscriber: AuthSubscriber) {
        if isAuthenticated {
            return
        }
        authSubscriber = subscriber
        c.auth(key, secret)
    }

    public func subscribe(_ channel: Channel) {
        c.subscribe(channel)
    }

    public func unsubscribe(_ channel: Channel) {
        c.unsubscribe(channel)
    }

    public func send(_ order: NewOrder) {
        c.send(order)
    }

    public func send(_ order: CancelOrder) {
        c.send(order)
    }

    public func send(_ orders: CancelOrderMulti) {
        c.send(orders)
    }

    public func send(_ ops: OrderMultiOP) {
        c.send(ops)
    }
}
