//
//  DevicesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PromiseKit

//TODO: Refactor this after DeviceError refactoring
class DevicesAPI: APIEndpoint {
    override var name: String { return "devices" }

    func retrieve(registrationId: String) -> Promise<Device?> {
        return Promise { fulfill, reject in
            retrieve(params: ["registration_id": registrationId]).then {
                fulfill($0.1.first)
            }.catch {
                reject($0)
            }
        }
    }

    func retrieve(userId: Int, page: Int = 1) -> Promise<(Meta, [Device])> {
        return retrieve(params: ["user": userId, "page": page])
    }

    func retrieve(deviceId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<Device> {
        return Promise { fulfill, reject in
            manager.request("\(StepicApplicationsInfo.apiURL)/\(self.name)/\(deviceId)", parameters: [:], headers: headers).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    reject(RetrieveError(error: error))
                case .success(let json):
                    if let r = response.response,
                        !(200...299 ~= r.statusCode) {
                        switch r.statusCode {
                        // when we pass wrong (but existing) device id we get 403 with error presented in field "detail"
                        case 403, 404:
                            return reject(DeviceError.notFound)
                        default:
                            return reject(DeviceError.other(error: nil, code: r.statusCode, message: json.rawString()))
                        }
                    }

                    fulfill(Device(json: json["devices"].arrayValue[0]))
                }
            }
        }
    }

    //TODO: Update this after errors refactoring. DeviceError is something that should be dealt with
    func update(_ device: Device, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<Device> {
        return Promise { fulfill, reject in
            guard let deviceId = device.id else {
                throw DeviceError.notFound
            }

            let params: Parameters? = [
                "device": device.json as AnyObject
            ]

            manager.request("\(StepicApplicationsInfo.apiURL)/\(self.name)/\(deviceId)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    reject(error)
                case .success(let json):
                    if let r = response.response,
                        !(200...299 ~= r.statusCode) {
                        switch r.statusCode {
                        case 404:
                            return reject(DeviceError.notFound)
                        default:
                            return reject(DeviceError.other(error: nil, code: r.statusCode, message: json.rawString()))
                        }
                    }

                    fulfill(Device(json: json["devices"].arrayValue[0]))
                }
            }
        }
    }

    //TODO: Update this after errors refactoring. DeviceError is something that should be dealt with
    func create(_ device: Device, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<Device> {
        let params = ["device": device.json]

        return Promise { fulfill, reject in
            manager.request("\(StepicApplicationsInfo.apiURL)/devices", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    reject(error)
                case .success(let json):
                    if let r = response.response,
                        !(200...299 ~= r.statusCode) {
                        switch r.statusCode {
                        case 404:
                            return reject(DeviceError.notFound)
                        default:
                            return reject(DeviceError.other(error: nil, code: r.statusCode, message: json.rawString()))
                        }
                    }

                    fulfill(Device(json: json["devices"].arrayValue[0]))
                }
            }
        }
    }

    //TODO: Update this after errors refactoring. DeviceError is something that should be dealt with
    func delete(_ deviceId: Int, headers: [String: String] = APIDefaults.headers.bearer) -> Promise<Void> {
        return Promise { fulfill, reject in
            manager.request("\(StepicApplicationsInfo.apiURL)/devices/\(deviceId)", method: .delete, headers: headers).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    reject(error)
                case .success(let json):
                    if let r = response.response,
                        !(200...299 ~= r.statusCode) {
                        switch r.statusCode {
                        case 404:
                            return reject(DeviceError.notFound)
                        default:
                            return reject(DeviceError.other(error: nil, code: r.statusCode, message: json.rawString()))
                        }
                    }

                    fulfill(())
                }
            }
        }
    }

    private func retrieve(params: Parameters, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<(Meta, [Device])> {
        return Promise { fulfill, reject in
            manager.request("\(StepicApplicationsInfo.apiURL)/\(self.name)", parameters: params, headers: headers).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    reject(RetrieveError(error: error))
                case .success(let json):
                    if let r = response.response,
                       !(200...299 ~= r.statusCode) {
                        switch r.statusCode {
                        case 404:
                            return reject(DeviceError.notFound)
                        default:
                            return reject(DeviceError.other(error: nil, code: r.statusCode, message: json.rawString()))
                        }
                    }

                    let meta = Meta(json: json["meta"])
                    let devices = json["devices"].arrayValue.map { Device(json: $0) }
                    fulfill((meta, devices))
                }
            }
        }
    }
}

enum DeviceError: Error {
    case notFound, other(error: Error?, code: Int?, message: String?)
}

extension DevicesAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func create(_ device: Device, headers: [String: String] = APIDefaults.headers.bearer, success: @escaping ((Device) -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request? {
        create(device, headers: headers).then { success($0) }.catch { errorHandler($0.localizedDescription) }
        return nil
    }

    @discardableResult func delete(_ deviceId: Int, headers: [String: String] = APIDefaults.headers.bearer, success: @escaping (() -> Void), error errorHandler: @escaping ((DeviceError) -> Void)) -> Request? {
        delete(deviceId, headers: headers).then { success() }.catch { errorHandler($0 as! DeviceError) }
        return nil
    }

    @discardableResult func retrieve(_ deviceId: Int, headers: [String: String] = APIDefaults.headers.bearer, success: @escaping ((Device) -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request? {
        retrieve(deviceId: deviceId, headers: headers).then { success($0) }.catch { errorHandler($0.localizedDescription) }
        return nil
    }
}
