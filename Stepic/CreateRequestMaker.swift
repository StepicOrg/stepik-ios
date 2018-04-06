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
    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, creatingObject: T, withManager manager: Alamofire.SessionManager) -> Promise<(T, JSON?)> {
        return Promise { fulfill, reject in
            let params: Parameters? = [
                paramName: creatingObject.json.dictionaryObject ?? ""
            ]

            checkToken().then {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)", method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        reject(error)
                    case .success(let json):
                        creatingObject.update(json: json[requestEndpoint].arrayValue[0])
                        fulfill((creatingObject, json))
                    }
                }
            }.catch {
                error in
                reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, creatingObject: T, withManager manager: Alamofire.SessionManager) -> Promise<T> {
        return Promise { fulfill, reject in
            request(requestEndpoint: requestEndpoint, paramName: paramName, creatingObject: creatingObject, withManager: manager).then { comment, _ in
                fulfill(comment)
            }.catch { error in
                reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, creatingObject: T, withManager manager: Alamofire.SessionManager) -> Promise<Void> {
        return Promise { fulfill, reject in
            request(requestEndpoint: requestEndpoint, paramName: paramName, creatingObject: creatingObject, withManager: manager).then { _, _ in
                fulfill(())
            }.catch { error in
                reject(error)
            }
        }
    }
}
