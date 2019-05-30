//
//  AssignmentsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import SwiftyJSON

class AssignmentsAPI: APIEndpoint {
    override var name: String { return "assignments" }

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Assignment], refreshMode: RefreshMode, success: @escaping (([Assignment]) -> Void), error errorHandler: @escaping ((NetworkError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }

    func retrieve(ids: [Assignment.IdType]) -> Promise<[Assignment]> {
        return Promise { seal in
            Assignment.fetchAsync(ids: ids).done { assignments in
                self.retrieve(ids: ids, existing: assignments, refreshMode: .update, success: { newAssignments in
                    seal.fulfill(newAssignments)
                }, error: { error in
                    seal.reject(error)
                })
            }
        }
    }
}
