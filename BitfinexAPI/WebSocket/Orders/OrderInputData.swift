import Foundation

public protocol OrderInputData {
    var data: [String: Any?] { get }
}

extension OrderInputData {
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
    
    func formatPrice(_ p: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ""
        f.thousandSeparator = ""
        return f.string(from: NSNumber(value: p)) ?? "0"
    }
}

public protocol NewOrder: OrderInputData {
}
