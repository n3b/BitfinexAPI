import Foundation

public struct UserCaps {
    public let orders: Perm
    public let account: Perm
    public let funding: Perm
    public let history: Perm
    public let wallets: Perm
    public let withdraw: Perm
    public let positions: Perm
    
    public struct Perm {
        public let read: Bool
        public let write: Bool
        
        init(_ read: Bool, _ write: Bool) {
            self.read = read
            self.write = write
        }
    }
    
    init(_ data: [String: [String: Int]]) throws {
        guard let orders = data["orders"],
            let account = data["account"],
            let funding = data["funding"],
            let history = data["history"],
            let wallets = data["wallets"],
            let withdraw = data["withdraw"],
            let positions = data["positions"] else {
                throw Basic.InvalidEntityStructure
        }
        
        self.orders = Perm(Bool(truncating: orders["read"] as NSNumber? ?? 0), Bool(truncating: orders["write"] as NSNumber? ?? 0))
        self.account = Perm(Bool(truncating: account["read"] as NSNumber? ?? 0), Bool(truncating: account["write"] as NSNumber? ?? 0))
        self.funding = Perm(Bool(truncating: funding["read"] as NSNumber? ?? 0), Bool(truncating: funding["write"] as NSNumber? ?? 0))
        self.history = Perm(Bool(truncating: history["read"] as NSNumber? ?? 0), Bool(truncating: history["write"] as NSNumber? ?? 0))
        self.wallets = Perm(Bool(truncating: wallets["read"] as NSNumber? ?? 0), Bool(truncating: wallets["write"] as NSNumber? ?? 0))
        self.withdraw = Perm(Bool(truncating: withdraw["read"] as NSNumber? ?? 0), Bool(truncating: withdraw["write"] as NSNumber? ?? 0))
        self.positions = Perm(Bool(truncating: positions["read"] as NSNumber? ?? 0), Bool(truncating: positions["write"] as NSNumber? ?? 0))
    }
}
