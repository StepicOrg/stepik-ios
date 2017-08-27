//
//  LastStepsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LastStepsAPI: APIEndpoint {
    let name = "last-steps"

    @discardableResult func retrieve(ids: [String], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, updatingLastSteps: [LastStep], success: @escaping (([LastStep]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, headers: headers, printOutput: false, ids: ids, deleteObjects: updatingLastSteps, refreshMode: .update, success: success, failure: errorHandler)

    }
}
