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
import PromiseKit

class ProfilesAPI: APIEndpoint {
    override var name: String { return "profiles" }

    func retrieve(ids: [Int], existing: [Profile], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<[Profile]> {
        return getObjectsByIds(ids: ids, updating: existing)
    }

    func update(_ profile: Profile, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<Profile> {
        return Promise { fulfill, reject in
            let params: Parameters? = [
                "profile": profile.json as AnyObject
            ]

            manager.request("\(StepicApplicationsInfo.apiURL)/\(self.name)/\(profile.id)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    reject(error) // raw error here
                case .success(let json):
                    profile.update(json: json["profiles"].arrayValue[0])
                    fulfill(profile)
                }
            }
        }
    }

}
