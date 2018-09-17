//
//  StepicsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class StepicsAPI: APIEndpoint {
    override var name: String { return "stepics" }

    func retrieveCurrentUser() -> Promise<User> {
        return Promise { seal in
            manager.request("\(StepicApplicationsInfo.apiURL)/\(name)/1", parameters: nil, encoding: URLEncoding.default, headers: AuthInfo.shared.initialHTTPHeaders).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    seal.reject(NetworkError(error: error))
                case .success(let json):
                    let user = User(json: json["users"].arrayValue[0])
                    let profile = Profile(json: json["profiles"].arrayValue[0])
                    user.profileEntity = profile
                    seal.fulfill(user)
                }
            }
        }
    }
}

extension StepicsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func retrieveCurrentUser(_ headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (User) -> Void, error errorHandler: @escaping (Error) -> Void) -> Request? {
        retrieveCurrentUser().done { success($0) }.catch { errorHandler($0) }
        return nil
    }
}
