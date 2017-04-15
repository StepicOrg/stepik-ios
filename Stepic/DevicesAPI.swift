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

class DevicesAPI: NSObject {
    
    let name = "devices"
    let manager : Alamofire.SessionManager
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        manager = Alamofire.SessionManager(configuration: configuration)
    }
    
    @discardableResult func create(_ device: Device, headers: [String: String] = APIDefaults.headers.bearer, success: @escaping ((Device)->Void), error errorHandler: @escaping ((String)->Void)) -> Request {
        let params = ["device": device.getJSON()]
        return manager.request("\(StepicApplicationsInfo.apiURL)/devices", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({
            response in
            
            var error = response.result.error
            var json : JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response
            
            
            print(json)
            
            if let e = error as? NSError {
                errorHandler("CREATE device: error \(e.domain) \(e.code): \(e.localizedDescription)")
                return
            }
            
            if response?.statusCode != 201 {
                errorHandler("CREATE device: bad response status code \(String(describing: response?.statusCode))")
                return
            }
            
            let device = Device(json: json["devices"].arrayValue[0])
            success(device)
            
            return
        })
    }
    
    @discardableResult func delete(_ deviceId: Int, headers: [String: String] = APIDefaults.headers.bearer, success: @escaping ((Void)->Void), error errorHandler: @escaping ((String)->Void)) -> Request {
        
        return manager.request("\(StepicApplicationsInfo.apiURL)/devices/\(deviceId)", method: .delete, headers: headers).response {
            response in
//            _, response, data, error in
            
            if let e = response.error as? NSError {
                errorHandler("DESTROY device: error \(e.domain) \(e.code): \(e.localizedDescription)")
                return
            }
            
            if response.response?.statusCode != 204 && response.response?.statusCode != 404 {
                errorHandler("DESTROY device: bad response status code \(String(describing: response.response?.statusCode))")
                return
            }
            
            success()
            
            return
        }
    }
    
    func retrieve(_ deviceId: Int, headers: [String: String] = APIDefaults.headers.bearer, success: @escaping ((Device)->Void), error errorHandler: @escaping ((String)-> Void)) -> Request {
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/devices/\(deviceId)", headers: headers).responseSwiftyJSON({
            response in
            
            var error = response.result.error
            var json : JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response
            
            
            if let e = error as? NSError {
                errorHandler("RETRIEVE device: error \(e.domain) \(e.code): \(e.localizedDescription)")
                return
            }
            
            if response?.statusCode != 200 {
                errorHandler("RETRIEVE device: bad response status code \(String(describing: response?.statusCode))")
                return
            }
            
            let device = Device(json: json["devices"].arrayValue[0])
            success(device)
            
            return
        })
    }
}
