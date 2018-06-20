import Foundation

public protocol SystemSubscriber: AnyObject {
    func connected()
    func disconnected()
    func onChannelError(_ error: Error)
    func onInfo(_ code: Int, _ msg: String)
    func onMaintenanceStart()
    func onMaintenanceEnd()
}

public protocol ChannelSubscriber: AnyObject {
    func onError(_ error: Basic, _ sender: Channel)
}

extension ChannelSubscriber {
    func onError(_ error: Basic, _ sender: Channel) {
    }
}

public protocol TradesSubscriber: ChannelSubscriber {
    func onTradesSnapshot(_ snapshot: [TradePrint])
    func onTradeExecuted(_ p: TradePrint)
    func onTradeUpdated(_ p: TradePrint)
}

public protocol TickerSubscriber: ChannelSubscriber {
    func onTickerUpdate(_ p: TickerPrint, _ symbol: Symbol)
}

public protocol BookSubscriber: ChannelSubscriber {
    func onBookSnapshot(_ snapshot: [BookPrint], _ symbol: Symbol)
    func onBookUpdate(_ p: BookPrint, _ symbol: Symbol)
}



public protocol AuthSubscriber: AnyObject {
}

public protocol AuthStatusSubscriber: AuthSubscriber {
    func onAuth(_ userId: Int, _ caps: UserCaps)
    func onAuthError(_ code: Int, _ msg: String)
}

public protocol AuthInfo: AuthSubscriber {
    func onBalanceInfo(_ info: BalanceInfo)
    func onMarginInfo(_ info: MarginInfo)
    func onNotification(_ notification: NotificationPrint)
}

public protocol AuthOrdersSubscriber: AuthSubscriber {
    func onOrdersSnapshot(_ snapshot: [OrderPrint])
    func onOrderCreated(_ p: OrderPrint)
    func onOrderUpdated(_ p: OrderPrint)
    func onOrderCanceled(_ p: OrderPrint)
}

public protocol AuthPositionsSubscriber: AuthSubscriber {
    func onPositionsSnapshot(_ p: [PositionPrint])
    func onPositionCreated(_ p: PositionPrint)
    func onPositionUpdated(_ p: PositionPrint)
    func onPositionCanceled(_ p: PositionPrint)
}

public protocol AuthTradesSubscriber: AuthSubscriber {
    func onAuthTradeExecuted(_ p: AuthTradePrint)
    func onAuthTradeUpdated(_ p: AuthTradePrint)
}

public protocol AuthWalletsSubscriber: AuthSubscriber {
    func onWalletSnapshot(_ snapshot: [WalletPrint])
    func onWalletUpdate(_ p: WalletPrint)
}
