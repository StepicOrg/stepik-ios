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
        return Promise { seal in
            let params: Parameters? = [
                paramName: creatingObject.json.dictionaryObject ?? ""
            ]

            checkToken().done {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)", method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        creatingObject.update(json: json[requestEndpoint].arrayValue[0])
                        seal.fulfill((creatingObject, json))
                    }
                }
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, creatingObject: T, withManager manager: Alamofire.SessionManager) -> Promise<T> {
        return Promise { seal in
            request(requestEndpoint: requestEndpoint, paramName: paramName, creatingObject: creatingObject, withManager: manager).done { comment, _ in
                seal.fulfill(comment)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, creatingObject: T, withManager manager: Alamofire.SessionManager) -> Promise<Void> {
        return Promise { seal in
            request(requestEndpoint: requestEndpoint, paramName: paramName, creatingObject: creatingObject, withManager: manager).done { _, _ in
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
