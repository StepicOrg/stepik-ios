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
    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, id: T.IdType, updatingObject: T? = nil, withManager manager: Alamofire.SessionManager) -> Promise<T> {
        return Promise { seal in
            checkToken().done {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)/\(id)", method: .get, encoding: URLEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        if updatingObject != nil {
                            updatingObject?.update(json: json[paramName].arrayValue[0])
                        } else {
                            seal.fulfill(T(json: json[paramName].arrayValue[0]))
                        }
                    }
                }
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, params: Parameters, updatingObjects: [T] = [], withManager manager: Alamofire.SessionManager) -> Promise<([T], Meta, JSON)> {
        return Promise { seal in
            checkToken().done {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)", method: .get, parameters: params, encoding: URLEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
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
                        seal.fulfill((resultArray, meta, json))
                        CoreDataHelper.instance.save()
                    }
                }
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, params: Parameters, updatingObjects: [T] = [], withManager manager: Alamofire.SessionManager) -> Promise<([T], Meta)> {
        return Promise { seal in
            request(requestEndpoint: requestEndpoint, paramName: paramName, params: params, updatingObjects: updatingObjects, withManager: manager).done {
                objects, meta, _ in
                seal.fulfill((objects, meta))
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }

    func requestWithFetching<T: IDFetchable>(requestEndpoint: String, paramName: String, params: Parameters, withManager manager: Alamofire.SessionManager) -> Promise<([T], Meta, JSON)> {
        return Promise { seal in
            checkToken().done {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)", method: .get, parameters: params, encoding: URLEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        let ids = json[paramName].arrayValue.compactMap { T.getId(json: $0) }
                        T.fetchAsync(ids: ids).done {
                            existingObjects in
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
                            seal.fulfill((resultArray, meta, json))
                            CoreDataHelper.instance.save()
                        }.catch {
                            error in
                            seal.reject(error)
                        }
                    }
                }
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }

    func requestWithFetching<T: IDFetchable>(requestEndpoint: String, paramName: String, params: Parameters, withManager manager: Alamofire.SessionManager) -> Promise<([T], Meta)> {
        return Promise { seal in
            requestWithFetching(requestEndpoint: requestEndpoint, paramName: paramName, params: params, withManager: manager).done {
                objects, meta, _ in
                seal.fulfill((objects, meta))
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, ids: [T.IdType], updating: [T], withManager manager: Alamofire.SessionManager) -> Promise<([T], JSON)> {
        let params: Parameters = [
            "ids": ids
        ]
        return Promise { seal in
            checkToken().done {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)", parameters: params, encoding: URLEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {

                    case .failure(let error):
                        seal.reject(NetworkError(error: error))

                    case .success(let json):
                        let jsonArray: [JSON] = json[paramName].array ?? []
                        let resultArray: [T] = jsonArray.map {
                            objectJSON in
                            if let recoveredIndex = updating.index(where: { $0.hasEqualId(json: objectJSON) }) {
                                updating[recoveredIndex].update(json: objectJSON)
                                return updating[recoveredIndex]
                            } else {
                                return T(json: objectJSON)
                            }
                        }

                        CoreDataHelper.instance.save()
                        seal.fulfill((resultArray, json))
                    }
                }
            }.catch { error in
                print("\(#file) \(#function) \(error)")
            }
        }
    }

    func request<T: JSONSerializable>(requestEndpoint: String, paramName: String, ids: [T.IdType], updating: [T], withManager manager: Alamofire.SessionManager) -> Promise<[T]> {
        return Promise { seal in
            request(requestEndpoint: requestEndpoint, paramName: paramName, ids: ids, updating: updating, withManager: manager).done {
                objects, _ in
                seal.fulfill(objects)
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }

}
