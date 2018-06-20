import Foundation

public protocol ApiErrorHandler {
    func handle(_ error: Error)
}

public class DumpHandler: ApiErrorHandler {
    public init(){}

    public func handle(_ error: Error) {
        dump(error)
    }
}
