//
//  AssignmentsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AssignmentsAPI: APIEndpoint {
    override var name: String { return "assignments" }

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Assignment], refreshMode: RefreshMode, success: @escaping (([Assignment]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, headers: headers, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }
}
