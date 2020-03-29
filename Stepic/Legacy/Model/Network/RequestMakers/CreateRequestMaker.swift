//
//  CreateRequestMaker.swift
//  Stepic
//
//  Created by Ostrenkiy on 20.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CreateRequestMaker {
    func request<T: JSONSerializable>(
        requestEndpoint: String,
        paramName: String,
        creatingObject: T,
        withManager manager: Alamofire.Session
    ) -> Promise<(T, JSON)> {
        Promise { seal in
            let params: Parameters? = [
                paramName: creatingObject.json.dictionaryObject ?? ""
            ]

            checkToken().done {
                manager.request(
                    "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)",
                    method: .post,
                    parameters: params,
                    encoding: JSONEncoding.default
                ).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        creatingObject.update(json: json[requestEndpoint].arrayValue[0])
                        seal.fulfill((creatingObject, json))
                    }
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(
        requestEndpoint: String,
        paramName: String,
        creatingObject: T,
        withManager manager: Alamofire.Session
    ) -> Promise<T> {
        Promise { seal in
            self.request(
                requestEndpoint: requestEndpoint,
                paramName: paramName,
                creatingObject: creatingObject,
                withManager: manager
            ).done { result, _ in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(
        requestEndpoint: String,
        paramName: String,
        creatingObject: T,
        withManager manager: Alamofire.Session
    ) -> Promise<Void> {
        Promise { seal in
            self.request(
                requestEndpoint: requestEndpoint,
                paramName: paramName,
                creatingObject: creatingObject,
                withManager: manager
            ).done { _, _ in
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
