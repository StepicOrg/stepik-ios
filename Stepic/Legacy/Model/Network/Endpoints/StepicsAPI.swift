//
//  StepicsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class StepicsAPI: APIEndpoint {
    override class var name: String { "stepics" }

    func retrieveCurrentUser() -> Promise<User> {
        Promise { seal in
            self.manager.request(
                "\(StepikApplicationsInfo.apiURL)/\(Self.name)/1",
                parameters: nil,
                encoding: URLEncoding.default,
                headers: AuthInfo.shared.initialHTTPHeaders
            ).responseSwiftyJSON { response in
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
    @discardableResult
    func retrieveCurrentUser(
        _ headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping (User) -> Void,
        error errorHandler: @escaping (Error) -> Void
    ) -> Request? {
        self.retrieveCurrentUser()
            .done { success($0) }
            .catch { errorHandler($0) }
        return nil
    }
}
