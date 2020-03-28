import Alamofire
import Foundation

final class AlamofireRequestsLogger: EventMonitor {
    let queue = DispatchQueue(label: "AlamofireRequestsLogger", qos: .background)

    func requestDidResume(_ request: Request) {
        guard let task = request.task,
              let request = task.originalRequest,
              let httpMethod = request.httpMethod,
              let requestURL = request.url?.absoluteString.removingPercentEncoding else {
            return
        }

        print("---------------------")
        print("Request: \(httpMethod) '\(requestURL)':")

        if let httpHeaderFields = request.allHTTPHeaderFields {
            print("Headers: [")
            for (key, value) in httpHeaderFields {
                print("  \(key): \(value)")
            }
            print("]")
        }

        if let httpBody = request.httpBody,
           let httpBodyString = String(data: httpBody, encoding: .utf8) {
            print("Body: \(httpBodyString)")
        }
    }
}
