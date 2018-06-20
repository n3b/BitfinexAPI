import Foundation

public struct Symbol: CustomStringConvertible, Hashable {
    public let value: String
    
    public var symbol: String {
        return "t\(value)"
    }
    
    public var pair: String {
        return String(value.suffix(6))
    }
    
    public static func ==(lhs: Symbol, rhs: Symbol) -> Bool {
        return lhs.value == rhs.value
    }
    
    public init?(_ fromString: String) {
        var str = fromString
        if str.count > 0 && str[str.startIndex] == "t" {
            str = String(str.dropFirst(1))
        }
        //        if str.count != 6 && str.count != 3 {
        //            return nil
        //        }
        value = str
    }
    
    public var description: String {
        return "\(value)"
    }
    
    public var hashValue: Int {
        return value.hashValue
    }
}
