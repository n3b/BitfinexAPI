import Foundation
import Starscream

class AuthChannel: Channel {
    var subscriber: AuthSubscriber?

    override func handleRawData(_ data: [Any]) throws {
        guard let name = data[1] as? String else {
            throw Basic.WebSocket("Unexpected Auth message name")
        }

        data.count == 2
                ? handleHeartbeat()
                : try handle(name, data[2])
    }

    func handle(_ name: String, _ rawData: Any) throws {
        do {
            switch (name, subscriber, rawData) {
                case ("wu", let s as AuthWalletsSubscriber, let data as [Any]):
                    let p = try WalletPrint(data)
                    s.onWalletUpdate(p)
                case ("on", let s as AuthOrdersSubscriber, let data as [Any]):
                    let p = try OrderPrint(data)
                    s.onOrderCreated(p)
                case ("ou", let s as AuthOrdersSubscriber, let data as [Any]):
                    let p = try OrderPrint(data)
                    s.onOrderUpdated(p)
                case ("oc", let s as AuthOrdersSubscriber, let data as [Any]):
                    let p = try OrderPrint(data)
                    s.onOrderCanceled(p)
                case ("pn", let s as AuthPositionsSubscriber, let data as [Any]):
                    let p = try PositionPrint(data)
                    s.onPositionCreated(p)
                    break
                case ("pu", let s as AuthPositionsSubscriber, let data as [Any]):
                    let p = try PositionPrint(data)
                    s.onPositionUpdated(p)
                    break
                case ("pc", let s as AuthPositionsSubscriber, let data as [Any]):
                    let p = try PositionPrint(data)
                    s.onPositionCanceled(p)
                    break
                case ("te", let s as AuthTradesSubscriber, let data as [Any]):
                    let p = try AuthTradePrint(data)
                    s.onAuthTradeExecuted(p)
                case ("tu", let s as AuthTradesSubscriber, let data as [Any]):
                    let p = try AuthTradePrint(data)
                    s.onAuthTradeUpdated(p)
                case ("bu", let s as AuthInfo, let data as [Any]):
                    let p = try BalanceInfo(data)
                    s.onBalanceInfo(p)
                case ("miu", let s as AuthInfo, let data as [Any]):
                    let p = try MarginInfo(data)
                    s.onMarginInfo(p)
                case ("n", let s as AuthInfo, let data as [Any]):
                    let p = try NotificationPrint(data)
                    s.onNotification(p)
//            case "fon", "fou", "foc", "fcn", "fcu", "fcc", "fln", "flu", "flc", "fiu", "fte", "ftu":
//                throw APIError.General("Funding is not supported yet")

                // snapshots:
                case ("os", let s as AuthOrdersSubscriber, let data as [[Any]]):
                    let snapshot = try data.map {
                        try OrderPrint($0)
                    }
                    s.onOrdersSnapshot(snapshot)
                case ("ws", let s as AuthWalletsSubscriber, let data as [[Any]]):
                    let snapshot = try data.map {
                        try WalletPrint($0)
                    }
                    s.onWalletSnapshot(snapshot)
                case ("ps", let s as AuthPositionsSubscriber, let data as [[Any]]):
                    let snapshot = try data.map {
                        try PositionPrint($0)
                    }
                    s.onPositionsSnapshot(snapshot)
                case ("ats", _, _): // algo? not documented
                    break
//                case "fos", "fcs", "fls":
//                throw APIError.General("Funding is not supported yet")


                default: throw Basic.General("Unsupported auth message '\(name)'")
            }
        }
    }

    override func handleHeartbeat() {
    }
}


