//
//  DiscussionProxiesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class DiscussionProxiesAPI: APIEndpoint {
    override var name: String { return "discussion-proxies" }

    func retrieve(id: String) -> Promise<DiscussionProxy> {
        return retrieve.request(requestEndpoint: "discussion-proxies", paramName: "discussion-proxies", id: id, withManager: manager)
    }
}

extension DiscussionProxiesAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func retrieve(_ id: String, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((DiscussionProxy) -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request? {
        retrieve(id: id).done { discussionProxy in
            success(discussionProxy)
        }.catch {
            error in
            errorHandler(error.localizedDescription)
        }
        return nil
    }
}
