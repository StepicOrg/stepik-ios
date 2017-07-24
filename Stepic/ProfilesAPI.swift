//
//  ProfilesAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ProfilesAPI: APIEndpoint {
    let name = "profiles"
    
    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Profile], refreshMode: RefreshMode, success: @escaping (([Profile]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, headers: headers, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }
    
    func update(_ profile: Profile, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Profile) -> Void), error errorHandler: @escaping ((String) -> Void)) {
        let params : Parameters? = [
            "profile" : profile.json as AnyObject
        ]
        Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)/\(profile.id)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({ response in
                var error = response.result.error
                var json: JSON = [:]
                if response.result.value == nil {
                    if error == nil {
                        error = NSError(domain: "", code: -1, userInfo: nil)
                    }
                } else {
                    json = response.result.value!
                }
                let response = response.response
            
                if let e = error as NSError? {
                    errorHandler("PUT profile: error \(e.domain) \(e.code): \(e.localizedDescription)")
                    return
                }
                
                if response?.statusCode != 200 {
                    errorHandler("PUT profile: bad response status code \(String(describing: response?.statusCode))")
                    return
                }
                
                let updatedProfile = Profile(json: json["profiles"].arrayValue[0])
                success(updatedProfile)
                
                return
            }
        )
    }
}
