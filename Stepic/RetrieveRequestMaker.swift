//
//  RetrieveRequestMaker.swift
//  Stepic
//
//  Created by Ostrenkiy on 27.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

class RetrieveRequestMaker {
    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, id: T.idType, updatingObject: T? = nil, withManager manager: Alamofire.SessionManager) -> Promise<T> {
        return Promise { fulfill, reject in
            checkToken().then {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)/\(id)", method: .get, encoding: JSONEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        reject(error)
                    case .success(let json):
                        if updatingObject != nil {
                            updatingObject?.update(json: json[paramName].arrayValue[0])
                        } else {
                            fulfill(T(json: json[paramName].arrayValue[0]))
                        }
                    }
                }
            }.catch {
                error in
                reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, params: Parameters, updatingObjects: [T], withManager manager: Alamofire.SessionManager) -> Promise<([T], Meta, JSON)> {
        return Promise { fulfill, reject in
            checkToken().then {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)/", method: .get, parameters: params, encoding: JSONEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        reject(error)
                    case .success(let json):
                        let jsonArray: [JSON] = json[paramName].array ?? []
                        let resultArray: [T] = jsonArray.map {
                            objectJSON in
                            if let recoveredIndex = updatingObjects.index(where: { $0.hasEqualId(json: objectJSON) }) {
                                updatingObjects[recoveredIndex].update(json: objectJSON)
                                return updatingObjects[recoveredIndex]
                            } else {
                                return T(json: objectJSON)
                            }
                        }
                        let meta = Meta(json: json["meta"])
                        fulfill((resultArray, meta, json))
                        CoreDataHelper.instance.save()
                    }
                }
                }.catch {
                    error in
                    reject(error)
            }
        }
    }

    func requestWithFetching<T: IDFetchable>(requestEndpoint: String, paramName: String, params: Parameters, withManager manager: Alamofire.SessionManager) -> Promise<([T], Meta, JSON)> {
        return Promise { fulfill, reject in
            checkToken().then {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)", method: .get, parameters: params, encoding: JSONEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        reject(error)
                    case .success(let json):
                        let ids = json[paramName].arrayValue.flatMap {T.getId(json: $0)}
                        T.fetchAsync(ids: ids).then {
                            existingObjects -> Void in
                            var resultArray: [T] = []
                            for objectJSON in json[paramName].arrayValue {
                                let existing = existingObjects.filter { obj in obj.hasEqualId(json: objectJSON) }

                                switch existing.count {
                                case 0:
                                    resultArray.append(T(json: objectJSON))
                                default:
                                    let obj = existing[0]
                                    obj.update(json: objectJSON)
                                    resultArray.append(obj)
                                }
                            }

                            CoreDataHelper.instance.save()

                            let meta = Meta(json: json["meta"])
                            fulfill((resultArray, meta, json))
                            CoreDataHelper.instance.save()
                        }.catch {
                            error in
                            reject(error)
                        }
                    }
                }
            }.catch {
                error in
                reject(error)
            }
        }
    }

    func requestWithFetching<T: IDFetchable>(requestEndpoint: String, paramName: String, params: Parameters, withManager manager: Alamofire.SessionManager) -> Promise<([T], Meta)> {
        return Promise { fulfill, reject in
            requestWithFetching(requestEndpoint: requestEndpoint, paramName: paramName, params: params, withManager: manager).then {
                objects, meta, _ in
                fulfill((objects, meta))
            }.catch {
                error in
                reject(error)
            }
        }
    }

}
