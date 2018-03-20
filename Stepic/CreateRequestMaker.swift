//
//  CreateRequestMaker.swift
//  Stepic
//
//  Created by Ostrenkiy on 20.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

class CreateRequestMaker {
    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, updatingObject: T, withManager manager: Alamofire.SessionManager) -> Promise<(T, JSON?)> {
        return Promise { fulfill, reject in
            let params: Parameters? = [
                paramName: updatingObject.json.dictionaryObject!
            ]

            checkToken().then {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)", method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        reject(error)
                    case .success(let json):
                        updatingObject.update(json: json[requestEndpoint].arrayValue[0])

                        fulfill((updatingObject, json))
                    }
                }
                }.catch {
                    error in
                    reject(error)
            }
        }
    }
}
