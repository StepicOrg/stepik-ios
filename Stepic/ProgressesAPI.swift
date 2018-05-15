//
//  ProgressesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ProgressesAPI: APIEndpoint {
    override var name: String { return "progresses" }

    @discardableResult func retrieve(ids: [String], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Progress], refreshMode: RefreshMode, success: @escaping (([Progress]) -> Void), error errorHandler: @escaping ((NetworkError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }
}
