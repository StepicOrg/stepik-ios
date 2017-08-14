//
//  CoursesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CoursesAPI: APIEndpoint {
    let name = "courses"

    @discardableResult func retrieveDisplayedIds(featured: Bool?, enrolled: Bool?, isPublic: Bool?, order: String?, page: Int?, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success : @escaping ([Int], Meta) -> Void, failure : @escaping (_ error: Error) -> Void) -> Request? {

        var params = Parameters()

        if let f = featured {
            params["is_featured"] = f ? "true" : "false"
        }

        if let e = enrolled {
            params["enrolled"] = e ? "true" : "false"
        }

        if let p = isPublic {
            params["is_public"] = p ? "true" : "false"
        }

        if let o = order {
            params["order"] = o
        }

        if let p = page {
            params["page"] = p
        }

        params["access_token"] = AuthInfo.shared.token?.accessToken as NSObject?

        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/courses", parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
            response in

            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
//            let response = response.response

            //TODO: Remove from here 
            if let e = error {
                print(e)
                failure(e)
                return
            }

            let meta = Meta(json: json["meta"])
            var res: [Int] = []

            for objectJSON in json["courses"].arrayValue {
                res += [objectJSON["id"].intValue]
            }
            success(res, meta)
        })
    }

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Course], refreshMode: RefreshMode, success: @escaping (([Course]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, headers: headers, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }
}
