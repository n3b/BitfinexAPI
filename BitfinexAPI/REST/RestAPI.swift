import Foundation

class RestAPI {
    typealias Params = [String: Any]

    let base = "https://api.bitfinex.com/v2"
    let void = { (d: Data?, r: URLResponse?, e: Error?) in }

    private func call(_ method: String = "GET", _ endpoint: String = "/", _ body: Data? = nil, _ completion: @escaping ((Response?, Error?) -> Void)) {
        var ep = endpoint
        if endpoint[endpoint.startIndex] != "/" {
            ep = "/\(ep)"
        }
        guard let url = URL(string: "\(base)\(ep)") else {
            print("cannot create URL")
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        if body != nil {
            urlRequest.httpBody = body!
        }
        let task = URLSession.shared.dataTask(with: urlRequest, completion)
        task.resume()
    }

    func get(_ e: String = "/", _ p: Params?, onResult: @escaping (Response) -> Void, onError: @escaping (Error) -> Void) {
        var url = e
        if p != nil {
            var components = URLComponents()
            components.queryItems = p!.map { (key: String, value: Any) in
                URLQueryItem(name: key, value: String(describing: value))
            }
            url = "\(url)\(components.url?.relativeString ?? "")"
        }

        call("GET", url, nil, completion(onResult, onError))
    }

    func post(_ e: String = "/",  _ p: Params?, onResult: @escaping (Response) -> Void, onError: @escaping (Error) -> Void) throws {
        var data: Data? = nil
        if p != nil {
            data = try JSONSerialization.data(withJSONObject: p!, options: [])
        }
        call("POST", e, data, completion(onResult, onError))
    }

    func ticker() {
        get("/ticker/tBTCUSD", nil, onResult: { res in dump(res) }, onError: { err in dump(err) })
    }
}

struct Response {
    let data: Any
    let metadata: URLResponse?
}

extension URLSession {
    func dataTask(with url: URLRequest, _ completion: @escaping ((Response?, Error?) -> Void)) -> URLSessionDataTask {
        return dataTask(with: url, completionHandler: { (maybeData, maybeResponse, maybeError) in
            if let data = maybeData {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    print("error trying to convert data to JSON")
                    return
                }
                completion(Response(data: json, metadata: maybeResponse), nil)
            } else if let error = maybeError {
                completion(nil, error)
            }
        })
    }
}

func completion<Result>(_ onResult: @escaping (Result) -> Void, _ onError: @escaping (Error) -> Void) -> ((Result?, Error?) -> Void) {
    return { (maybeResult, maybeError) in
        if let result = maybeResult {
            onResult(result)
        } else if let error = maybeError {
            onError(error)
        } else {
            onError(SplitError.NoResultFound)
        }
    }
}

enum SplitError: Error {
    case NoResultFound
}


