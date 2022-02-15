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
    func request(
        requestEndpoint: String,
        bodyJSONObject body: Any,
        withManager manager: Alamofire.Session
    ) -> Promise<JSON> {
        guard let url = URL(string: "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)") else {
            return Promise(error: Error.badRequest)
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return Promise(error: Error.badRequest)
        }

        return Promise { seal in
            checkToken().done {
                manager.request(request).validate().responseSwiftyJSON { response in
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

    enum Error: Swift.Error {
        case badRequest
    }
}

// MARK: - Response Decodable -

extension CreateRequestMaker {
    func requestDecodable<T: Decodable>(
        requestEndpoint: String,
        bodyJSONObject body: Any,
        withManager manager: Alamofire.Session
    ) -> Promise<T> {
        guard let url = URL(string: "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)") else {
            return Promise(error: Error.badRequest)
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return Promise(error: Error.badRequest)
        }

        return Promise { seal in
            checkToken().done {
                manager.request(request).validate().responseDecodable { (response: AFDataResponse<T>) in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success(let decodable):
                        seal.fulfill(decodable)
                    }
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func requestDecodableObjects<T: Decodable>(
        requestEndpoint: String,
        bodyJSONObject body: Any,
        withManager manager: Alamofire.Session
    ) -> Promise<DecodedObjectsResponse<T>> {
        self.requestDecodable(requestEndpoint: requestEndpoint, bodyJSONObject: body, withManager: manager)
    }
}
