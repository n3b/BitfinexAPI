import Foundation
import Starscream

class Client: WebSocketDelegate {

    let queueIn = DispatchQueue(label: "tools.n3b.BitfinexAPI.in")
    let queueOut = DispatchQueue(label: "tools.n3b.BitfinexAPI.out")
    let socket: WebSocket

    let pending = ConcurrentDictionary<ChannelKey, Channel>()
    let channels = ConcurrentDictionary<Int, Channel>()

    var errorHandler: ApiErrorHandler?
    var subscriber: SystemSubscriber?

    var pingId = 0
    var maintenance = false
    var isAuthenticated = false

    var authSubscriber: AuthSubscriber? {
        get {
            return (channels[0] as! AuthChannel).subscriber
        }
        set {
            (channels[0] as! AuthChannel).subscriber = newValue
        }
    }

    init(_ url: String) {
        socket = WebSocket(url: URL(string: url)!)

        channels[0] = AuthChannel()

        socket.delegate = self
        // stub to prevent ws from using main queue
        socket.callbackQueue = DispatchQueue(label: "WebSocket.callback")
    }

    func websocketDidConnect(socket: WebSocketClient) {
        queueIn.async(flags: .barrier) { [weak self] in
            guard let pending = self?.pending else {return}
            for (_, v) in pending {
                self?.sendSubscribe(v as! ChannelStringCommand)
            }
            self?.subscriber?.connected()
        }
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        queueIn.async(flags: .barrier) { [weak self] in
            guard let channels = self?.channels, let pending = self?.pending else {return}

            self?.isAuthenticated = false
            self?.maintenance = false
            self?.pingId = 0

            let auth = channels[0]
            channels[0] = nil
            let old = channels.values
            channels.removeAll()
            channels[0] = auth

            for channel in old {
                pending[(channel as! ChannelKeyCont).key] = channel
            }
            
            if error != nil {
                if let err = error as? Starscream.WSError {
                    self?.onError(Basic.WebSocket("Disconnected: \(err.code) \(err.message)"))
                } else {
                    self?.onError(Basic.WebSocket("Disconnected: \(error!.localizedDescription)"))
                }
            }

            self?.subscriber?.disconnected()
        }
    }

    func onError(_ error: Error) {
#if DEBUG
        print(">>> Error: \(error.localizedDescription)")
#endif
        errorHandler?.handle(error)
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
#if DEBUG
    print("in: \(text)")
#endif
        queueIn.async(flags: .barrier) { [weak self] in
            do {
                let data = text.data(using: .utf8)
                guard let json = try? JSONSerialization.jsonObject(with: data!) else {
                    throw Basic.WebSocket("Invalid json received")
                }

                switch json {
                    case let message as [String: Any]:
                        try self?.handle(message)
                    case let payload as [Any]:
                        try self?.handle(payload)
                    default: throw Basic.General("Unsupported json")
                }
            } catch let error {
                self?.onError(error)
            }
        }
    }

    func handle(_ data: [String: Any]) throws {
        guard let event = try Event.parse(data) else {
            throw Basic.WebSocket("Invalid event message")
        }

        switch event {
            case let .Subscribed(cid, key):
                guard let ch = pending[key] else {
                    throw Basic.General("Pending channel not found")
                }
                pending[key] = nil
                channels[cid] = ch
                ch.id = cid
            case let .Unsubscribed(cid):
                guard channels[cid] != nil else {
                    throw Basic.General("There is no channel with id \(cid)")
                }
                channels[cid] = nil
            case let .Error(code, msg):
                throw Basic.WebSocketBF("\(msg)", code)
            case let .ChannelError(code, msg, key):
                let error = Basic.WebSocketBF("\(msg) \(key.symbol)", code)
                if let channel = pending[key] {
                    channel.onError(error)
                }
                pending[key] = nil
                throw error
            case .Greeting(_):
                break
            case let .AuthSuccess(userId, caps):
                isAuthenticated = true
                (authSubscriber as? AuthStatusSubscriber)?.onAuth(userId, try UserCaps(caps))
            case let .AuthFailure(code, msg):
                isAuthenticated = false
                (authSubscriber as? AuthStatusSubscriber)?.onAuthError(code, msg)
                throw Basic.WebSocketBF("\"\(msg)\"", code)
            case let .Info(code, msg):
                switch code {
                    case 20051:
                        disconnect()
                        connect()
                    case 20060:
                        maintenance = true
                        subscriber?.onMaintenanceStart()
                    case 20061:
                        maintenance = false
                        subscriber?.onMaintenanceEnd()
                    default: throw Basic.WebSocket("Unsupported Info code \(code)")
                }
                subscriber?.onInfo(code, msg)
            case .Pong(_, _):
                print("pong")
        }
    }

    func handle(_ data: [Any]) throws {
        if data.count < 2 {
            throw Basic.WebSocket("Unexpected payload format")
        }
        guard let cid = data[0] as? Int else {
            throw Basic.WebSocket("Missing channel ID")
        }

        guard let channel = channels[cid] else {
            throw Basic.General("Unknown channel id '\(cid)'")
        }

        try channel.handleRawData(data)
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        onError(Basic.WebSocket("Unexpected function call"))
    }

    func connect() {
        queueOut.async {
            if !self.socket.isConnected {
                self.socket.connect()
            }
        }
    }

    func disconnect() {
        queueOut.async {
            self.socket.disconnect()
        }
    }

    func ping() {
        queueOut.async {
            self.pingId = self.pingId == 1_000_000 ? 1 : self.pingId + 1
            self.socket.write(string: "{\"event\":\"ping\",\"cid\":\(self.pingId)}")
        }
    }

    func auth(_ key: String, _ secret: String) {
        queueOut.async {
            let nonce = round(Date().timeIntervalSince1970 * 1_000_000)
            let authPayload = "AUTH\(nonce)"
            let sig = authPayload.hmac(.SHA384, key: secret)
            let payload: [String: Any] = [
                "apiKey": key,
                "authSig": sig,
                "authNonce": nonce,
                "authPayload": authPayload,
                "event": "auth",
                "filter": [
                    "trading", //orders, positions, trades
//                    "funding", //offers, credits, loans, funding trades
                    "wallet", //wallet
                    "algo", //algorithmic orders
                    "balance" //balance (tradable balance, ...)
                ]
            ]
            do {
                let json = try JSONSerialization.data(withJSONObject: payload)
                let str = String(data: json, encoding: String.Encoding.utf8)!
                self.socket.write(string: str)
            } catch let error {
                self.errorHandler?.handle(error)
            }
        }
    }

    func subscribe(_ ch: Channel) {
        pending[(ch as! ChannelKeyCont).key] = ch
        sendSubscribe(ch as! ChannelStringCommand)
    }

    func unsubscribe(_ channel: Channel) {
        if channel.id != nil {
            pending[(channel as! ChannelKeyCont).key] = nil
            sendUnsubscribe(channel.id!)
        }
    }

    private func sendSubscribe(_ ch: ChannelStringCommand) {
        if socket.isConnected {
#if DEBUG
            print(ch.subscribeString)
#endif

            queueOut.async(flags: .barrier) {
                self.socket.write(string: ch.subscribeString)
            }
        }
    }

    private func sendUnsubscribe(_ id: Int) {
        if socket.isConnected {
#if DEBUG
                print("unsubscribe: \(id)")
#endif

            queueOut.async {
                self.socket.write(string: "{\"event\":\"unsubscribe\", \"chanId\":\(id)}")
            }
        }
    }

    func send(_ order: NewOrder) {
        sendData([0, "on", nil, order.data])
    }

    func send(_ order: CancelOrder) {
        sendData([0, "oc", nil, order.data])
    }

    func send(_ orders: CancelOrderMulti) {
        sendData([0, "oc_multi", nil, orders.data])
    }

    func send(_ ops: OrderMultiOP) {
        sendData([0, "ox_multi", nil, ops.data])
    }

    private func sendData(_ data: Any) {
        if socket.isConnected && isAuthenticated && !maintenance {
            queueOut.async(flags: .barrier) {
                do {
                    let data = try JSONSerialization.data(withJSONObject: data)
                    let str = String(data: data, encoding: .utf8)
#if DEBUG
                    print("out: \(str!)")
#endif
                    self.socket.write(string: str!)
                } catch let error {
                    self.errorHandler?.handle(error)
                }
            }
        }
    }
}
