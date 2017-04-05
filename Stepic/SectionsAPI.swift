//
//  SectionsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SectionsAPI : APIEndpoint {
    let name = "sections"
    
    func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Section], refreshMode: RefreshMode, success: @escaping (([Section]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, headers: headers, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }    
}
