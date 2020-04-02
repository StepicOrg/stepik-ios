//
//  DiscussionProxiesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class DiscussionProxiesAPI: APIEndpoint {
    override var name: String { "discussion-proxies" }

    func retrieve(id: String) -> Promise<DiscussionProxy> {
        self.retrieve.request(
            requestEndpoint: "discussion-proxies",
            paramName: "discussion-proxies",
            id: id,
            withManager: self.manager
        )
    }
}

extension DiscussionProxiesAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func retrieve(
        _ id: String,
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping ((DiscussionProxy) -> Void),
        error errorHandler: @escaping ((String) -> Void)
    ) -> Request? {
        self.retrieve(id: id).done { discussionProxy in
            success(discussionProxy)
        }.catch { error in
            errorHandler(error.localizedDescription)
        }
        return nil
    }
}
