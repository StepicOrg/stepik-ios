//
//  RequestChain.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire

class RequestChain {
    typealias CompletionHandler = (_ success: Bool, _ errorResult: ErrorResult?) -> Void

    struct ErrorResult {
        let request: URLRequest?
        let error: Error?
    }

    fileprivate var requests: [Request] = []

    init(requests: [Request]) {
        self.requests = requests
    }

    func start(_ completionHandler: @escaping CompletionHandler) {
        if let request = requests.first {
            AlamofireDefaultSessionManager.shared.request(request as! URLRequestConvertible).response {
                response in
                if response.error != nil {
                    completionHandler(false, ErrorResult(request: response.request, error: response.error))
                    return
                }
                self.requests.removeFirst()
                self.start(completionHandler)
            }
            request.resume()
        } else {
            completionHandler(true, nil)
            return
        }

    }
}
