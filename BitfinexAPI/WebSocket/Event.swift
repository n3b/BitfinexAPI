enum Event {
    case Subscribed(cid: Int, key: ChannelKey)
    case Unsubscribed(cid: Int)
    case Greeting(version: Int)
    case Info(code: Int, msg: String)
    case Error(code: Int, msg: String)
    case ChannelError(code: Int, msg: String, key: ChannelKey)
    case Pong(cid: Int, ts: Double)
    case AuthSuccess(userId: Int, caps: [String: [String: Int]])
    case AuthFailure(code: Int, msg: String)

    static func parse(_ json: [String: Any]) throws -> Event? {
        var event: Event?

        switch json["event"] as? String {

            case "subscribed"?:
                let symbol = json["symbol"] as? String
                let pair = json["pair"] as? String
                guard let s = Symbol(symbol ?? pair ?? ""),
                      let id = json["chanId"] as? Int,
                      let channel = json["channel"] as? String,
                      let type = Channel.type(rawValue: channel)
                        else {
                    throw Basic.General("Unsupported Subscribed response")
                }

                event = .Subscribed(cid: id, key: ChannelKey(type, s))

            case "unsubscribed"?:
                guard let id = json["chanId"] as? Int, json["status"] as? String == "OK" else {
                    throw Basic.General("Unsupported Unsubscribed response")
                }
                event = .Unsubscribed(cid: id)

            case "auth"?:
                if json["status"] as? String == "OK" {
                    guard let id = json["userId"] as? Int,
                          let caps = json["caps"] as? [String: [String: Int]] else {
                        throw Basic.General("Unsupported Auth response")
                    }
                    event = .AuthSuccess(userId: id, caps: caps)
                } else {
                    guard let code = json["code"] as? Int,
                          let msg = json["msg"] as? String else {
                        throw Basic.General("Unsupported Auth response")
                    }
                    event = .AuthFailure(code: code, msg: msg)
                }

            case "info"?:
                if let version = json["version"] as? Int {
                    if version != 2 {
                        throw Basic.General("Unsupported version: \(version)")
                    }
                    event = Greeting(version: 2)
                } else {
                    guard let code = json["code"] as? Int, code == 20051 || code == 20060 || code == 20061 else {
                        throw Basic.General("Unknown info code")
                    }
                    event = Info(code: code, msg: json["msg"] as? String ?? "")
                }

            case "error"?:
                guard let code = json["code"] as? Int else {
                    throw Basic.General("Unknown error code")
                }
                let s = json["symbol"] as? String ?? json["pair"] as? String ?? ""
                if let symbol = Symbol(s),
                   let channel = Channel.type(rawValue: json["channel"] as? String ?? "") {
                    event = ChannelError(code: code, msg: json["msg"] as? String ?? "", key: ChannelKey(channel, symbol))
                } else {
                    event = Error(code: code, msg: json["msg"] as? String ?? "")
                }

            case "pong"?:
                guard let cid = json["cid"] as? Int, let ts = json["ts"] as? Double else {
                    throw Basic.General("Unsupported Pong format")
                }
                event = Pong(cid: cid, ts: ts)

            default: throw Basic.General("Unsupported event \(json["event"] ?? "")")
        }

        return event
    }
}
