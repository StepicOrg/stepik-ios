//
//  UpdateRequestMaker.swift
//  Stepic
//
//  Created by Ostrenkiy on 20.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class UpdateRequestMaker {
    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, updatingObject: T, withManager manager: Alamofire.SessionManager) -> Promise<T> {
        return Promise { seal in
            let params: Parameters? = [
                paramName: updatingObject.json.dictionaryObject ?? ""
            ]

            checkToken().done {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)/\(updatingObject.id)", method: .put, parameters: params, encoding: JSONEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        updatingObject.update(json: json[requestEndpoint].arrayValue[0])
                        seal.fulfill(updatingObject)
                    }
                }
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }
}
