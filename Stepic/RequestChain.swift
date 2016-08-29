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
    typealias CompletionHandler = (success: Bool, errorResult: ErrorResult?) -> Void
    
    struct ErrorResult {
        let request: Request?
        let error: ErrorType?
    }
    
    private var requests:[Request] = []
    
    init(requests: [Request]) {
        self.requests = requests
    }
    
    func start(completionHandler: CompletionHandler) {
        if let request = requests.first {
            request.response(completionHandler: { (_, _, _, error) in
                if error != nil {
                    completionHandler(success: false, errorResult: ErrorResult(request: request, error: error))
                    return
                }
                self.requests.removeFirst()
                self.start(completionHandler)
            })
            request.resume()
        } else {
            completionHandler(success: true, errorResult: nil)
            return
        }
        
    }
}