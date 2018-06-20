import Foundation

public enum OrderType: String {
    case Market = "MARKET"
    case Limit = "LIMIT"
    case Fok = "FOK"
    case Stop = "STOP"
    case StopLimit = "STOP LIMIT"
    case TrStop = "TRAILING STOP"
    
    case ExMarket = "EXCHANGE MARKET"
    case ExLimit = "EXCHANGE LIMIT"
    case ExStop = "EXCHANGE STOP"
    case ExStopLimit = "EXCHANGE STOP LIMIT"
    case ExTrStop = "EXCHANGE TRAILING STOP"
    case ExFok = "EXCHANGE FOK"
    
    case Unknown
}
