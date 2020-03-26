//
//  UpdateRequestMaker.swift
//  Stepic
//
//  Created by Ostrenkiy on 20.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class UpdateRequestMaker {
    func request<T: JSONSerializable>(
        requestEndpoint: String,
        paramName: String,
        updatingObject: T,
        withManager manager: Alamofire.Session
    ) -> Promise<(T, JSON)> {
        Promise { seal in
            let params: Parameters? = [
                paramName: updatingObject.json.dictionaryObject ?? ""
            ]

            checkToken().done {
                manager.request(
                    "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)/\(updatingObject.id)",
                    method: .put,
                    parameters: params,
                    encoding: JSONEncoding.default
                ).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        updatingObject.update(json: json[requestEndpoint].arrayValue[0])
                        seal.fulfill((updatingObject, json))
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
        updatingObject: T,
        withManager manager: Alamofire.Session
    ) -> Promise<T> {
        Promise { seal in
            self.request(
                requestEndpoint: requestEndpoint,
                paramName: paramName,
                updatingObject: updatingObject,
                withManager: manager
            ).done { updatedObject, _ in
                seal.fulfill(updatedObject)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
