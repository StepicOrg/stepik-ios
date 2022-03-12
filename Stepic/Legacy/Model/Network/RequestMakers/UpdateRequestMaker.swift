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

// MARK: - Codable Support -

extension UpdateRequestMaker {
    func requestCodable<E: Encodable, D: Decodable>(
        encodableType: E.Type = E.self,
        decodableType: D.Type = D.self,
        requestEndpoint: String,
        paramName: String,
        updatingObject: E,
        withManager manager: Alamofire.Session,
        withEncoder encoder: JSONEncoder = JSONEncoder()
    ) -> Promise<D> {
        Promise { seal in
            let updatingObjectDictionary: [String: Any]? = {
                do {
                    let dictionary = try self.encodableToDictionary(updatingObject, encoder: encoder)
                    return dictionary
                } catch {
                    #if DEBUG
                    fatalError(error.localizedDescription)
                    #else
                    return nil
                    #endif
                }
            }()

            let params: Parameters? = [
                paramName: updatingObjectDictionary ?? ""
            ]

            checkToken().done {
                manager.request(
                    "\(StepikApplicationsInfo.apiURL)/\(requestEndpoint)",
                    method: .put,
                    parameters: params,
                    encoding: JSONEncoding.default
                ).validate().responseDecodable { (response: AFDataResponse<D>) in
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

    func requestCodableResponseDecodedObjects<T: Codable>(
        requestEndpoint: String,
        paramName: String,
        updatingObject: T,
        withManager manager: Alamofire.Session,
        withEncoder encoder: JSONEncoder = JSONEncoder()
    ) -> Promise<DecodedObjectsResponse<T>> {
        self.requestCodable(
            encodableType: T.self,
            decodableType: DecodedObjectsResponse<T>.self,
            requestEndpoint: requestEndpoint,
            paramName: paramName,
            updatingObject: updatingObject,
            withManager: manager,
            withEncoder: encoder
        )
    }

    // MARK: Private Helpers

    private func encodableToDictionary<T: Encodable>(
        _ encodableObject: T,
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> [String: Any] {
        let data = try encoder.encode(encodableObject)

        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw Error.jsonSerializationFailed
        }

        return dictionary
    }

    private enum Error: Swift.Error {
        case jsonSerializationFailed
    }
}
