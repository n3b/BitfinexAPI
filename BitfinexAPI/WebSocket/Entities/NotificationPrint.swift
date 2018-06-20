import Foundation

public struct NotificationPrint: AuthPrint {
    public let created: Date
    public let id: Int?
    public let info: NotifyInfo
    public let code: Int?
    public let status: Status
    public let text: String
    
    public enum Status: String {
        case Success = "SUCCESS"
        case Error = "ERROR"
        case Failure = "FAILURE"
        case Unknown
    }
    
    public enum NotifyInfo {
        case NewOrderRequest(cid: Int32)
        case CancelOrderRequest(id: UInt64, cid: Int32?)
        case Unknown
    }
    
    //    let demo: [Any] = [0, "n", [
    //        1516209922493,
    //        "on-req",
    //        nil,
    //        nil,
    //        [
    //            nil,
    //            nil,
    //            1516209922, // cid
    //            nil,
    //            nil,
    //            nil,
    //            0.005, // amount
    //            nil,
    //            "EXCHANGE LIMIT", // type
    //            nil,
    //            nil,
    //            nil,
    //            nil,
    //            ACTIVE, // status
    //            nil,
    //            nil,
    //            2000, // price
    //            nil,
    //            nil,
    //            nil,
    //            nil,
    //            nil,
    //            nil,
    //            0, // notify
    //            0, // hidden
    //            nil
    //        ],
    //        nil,
    //        "ERROR",
    //        "symbol: invalid"
    //    ]]
    
    // oc-req
    
    init(_ data: [Any]) throws {
        if data.count < 8 {
            throw Basic.InvalidEntityStructure
        }
        
        guard let created = data[0] as? TimeInterval,
            let type = data[1] as? String,
            let status = data[6] as? String,
            let text = data[7] as? String,
            let info = data[4] as? [Any]
            else {
                throw Basic.InvalidEntityStructure
        }
        
        code = data[5] as? Int
        id = data[2] as? Int
        self.created = Date(timeIntervalSince1970: created / 1_000)
        self.status = Status(rawValue: status) ?? .Unknown
        self.text = text
        
        switch type {
        case "on-req":
            guard let cid = info[2] as? Int32
                else {
                    throw Basic.InvalidEntityStructure
            }
            self.info = .NewOrderRequest(cid: cid)
        case "oc-req":
            guard let id = info[0] as? UInt64 else {
                throw Basic.InvalidEntityStructure
            }
            let cid = info[2] as? Int32
            self.info = .CancelOrderRequest(id: id, cid: cid)
        default:
            self.info = .Unknown
        }
    }
}
