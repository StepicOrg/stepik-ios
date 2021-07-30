//
//  RetrieveRequestMaker.swift
//  Stepic
//
//  Created by Ostrenkiy on 27.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class RetrieveRequestMaker {
    func request(
        requestEndpoint: String,
        params: Parameters? = nil,
        withManager manager: Alamofire.Session
    ) -> Promise<JSON> {
        Promise { seal in
            checkToken().done {
                manager.request(
                    "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)",
                    parameters: params,
                    encoding: URLEncoding.default
                ).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        seal.fulfill(json)
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
        id: T.IdType,
        updatingObject: T? = nil,
        withManager manager: Alamofire.Session
    ) -> Promise<T> {
        Promise { seal in
            checkToken().done {
                manager.request(
                    "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)/\(id)",
                    method: .get,
                    encoding: URLEncoding.default
                ).validate().responseSwiftyJSON { response in
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
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func request<T: JSONSerializable>(
        requestEndpoint: String,
        paramName: String,
        params: Parameters,
        updatingObjects: [T] = [],
        withManager manager: Alamofire.Session
    ) -> Promise<([T], Meta, JSON)> {
        Promise { seal in
            checkToken().done {
                manager.request(
                    "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)",
                    method: .get,
                    parameters: params,
                    encoding: URLEncoding.default
                ).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        let jsonArray: [JSON] = json[paramName].array ?? []
                        let resultArray: [T] = jsonArray.map { objectJSON in
                            if let recoveredIndex = updatingObjects.firstIndex(where: { $0.hasEqualId(json: objectJSON) }) {
                                updatingObjects[recoveredIndex].update(json: objectJSON)
                                return updatingObjects[recoveredIndex]
                            } else {
                                return T(json: objectJSON)
                            }
                        }
                        let meta = Meta(json: json["meta"])
                        seal.fulfill((resultArray, meta, json))
                        CoreDataHelper.shared.save()
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
        params: Parameters,
        updatingObjects: [T] = [],
        withManager manager: Alamofire.Session
    ) -> Promise<([T], Meta)> {
        Promise { seal in
            self.request(
                requestEndpoint: requestEndpoint,
                paramName: paramName,
                params: params,
                updatingObjects: updatingObjects,
                withManager: manager
            ).done { objects, meta, _ in
                seal.fulfill((objects, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func requestWithCollectAllPages<T: JSONSerializable>(
        requestEndpoint: String,
        paramName: String,
        params: Parameters,
        updatingObjects: [T] = [],
        withManager manager: Alamofire.Session
    ) -> Promise<[T]> {
        var allObjects = [T]()

        func load(page: Int) -> Promise<Bool> {
            Promise { seal in
                firstly { () -> Promise<([T], Meta)> in
                    var currentPageParams = params
                    currentPageParams["page"] = page

                    return self.request(
                        requestEndpoint: requestEndpoint,
                        paramName: paramName,
                        params: currentPageParams,
                        updatingObjects: updatingObjects,
                        withManager: manager
                    )
                }.done { objects, meta in
                    allObjects.append(contentsOf: objects)
                    seal.fulfill(meta.hasNext)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }

        func collect(page: Int) -> Promise<[T]> {
            load(page: page).then { hasNext -> Promise<[T]> in
                if hasNext {
                    return collect(page: page + 1)
                } else {
                    return .value(allObjects)
                }
            }
        }

        return collect(page: 1)
    }

    func requestWithFetching<T: IDFetchable>(
        requestEndpoint: String,
        paramName: String,
        params: Parameters,
        withManager manager: Alamofire.Session
    ) -> Promise<([T], Meta, JSON)> {
        Promise { seal in
            checkToken().done {
                manager.request(
                    "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)",
                    method: .get,
                    parameters: params,
                    encoding: URLEncoding.default
                ).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        let ids = json[paramName].arrayValue.compactMap { T.getId(json: $0) }
                        T.fetchAsync(ids: ids).done { existingObjects in
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

                            CoreDataHelper.shared.save()

                            let meta = Meta(json: json["meta"])
                            seal.fulfill((resultArray, meta, json))
                            CoreDataHelper.shared.save()
                        }.catch { error in
                            seal.reject(error)
                        }
                    }
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func requestWithFetching<T: IDFetchable>(
        requestEndpoint: String,
        paramName: String,
        params: Parameters,
        withManager manager: Alamofire.Session
    ) -> Promise<([T], Meta)> {
        Promise { seal in
            self.requestWithFetching(
                requestEndpoint: requestEndpoint,
                paramName: paramName,
                params: params,
                withManager: manager
            ).done { objects, meta, _ in
                seal.fulfill((objects, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func request<IdType: Equatable>(
        requestEndpoint: String,
        ids: [IdType],
        withManager manager: Alamofire.Session
    ) -> Promise<JSON> {
        if ids.isEmpty {
            return .value([:])
        }

        let params: Parameters = [
            "ids": ids
        ]

        return Promise { seal in
            checkToken().done {
                manager.request(
                    "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)",
                    parameters: params,
                    encoding: URLEncoding.default
                ).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        seal.fulfill(json)
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
        ids: [T.IdType],
        updating: [T],
        withManager manager: Alamofire.Session
    ) -> Promise<([T], JSON)> {
        if ids.isEmpty {
            return .value(([], [:]))
        }

        let params: Parameters = [
            "ids": ids
        ]

        return Promise { seal in
            checkToken().done {
                manager.request(
                    "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)",
                    parameters: params,
                    encoding: URLEncoding.default
                ).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let json):
                        let jsonArray: [JSON] = json[paramName].array ?? []
                        let resultArray: [T] = jsonArray.map { objectJSON in
                            if let recoveredIndex = updating.firstIndex(where: { $0.hasEqualId(json: objectJSON) }) {
                                updating[recoveredIndex].update(json: objectJSON)
                                return updating[recoveredIndex]
                            } else {
                                return T(json: objectJSON)
                            }
                        }

                        CoreDataHelper.shared.save()
                        seal.fulfill((resultArray, json))
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
        ids: [T.IdType],
        updating: [T],
        withManager manager: Alamofire.Session
    ) -> Promise<[T]> {
        Promise { seal in
            self.request(
                requestEndpoint: requestEndpoint,
                paramName: paramName,
                ids: ids,
                updating: updating,
                withManager: manager
            ).done { objects, _ in
                seal.fulfill(objects)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
