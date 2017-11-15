//
//  StepsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class StepsAPI: APIEndpoint {
    override var name: String { return "steps" }

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Step], refreshMode: RefreshMode, success: @escaping (([Step]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, headers: headers, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }
}
