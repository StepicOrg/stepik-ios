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
    let manager : Alamofire.Manager
    
    override init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 5
        manager = Alamofire.Manager(configuration: configuration)
    }
    
    func create(device: Device, headers: [String: String] = APIDefaults.headers.bearer, success: (Device->Void), error errorHandler: (String->Void)) -> Request {
        let params = ["device": device.getJSON()]
        return manager.request(.POST, "\(StepicApplicationsInfo.apiURL)/devices", parameters: params, encoding: .JSON, headers: headers).responseSwiftyJSON({
            _, response, json, error in
            
            print(json)
            
            if let e = error as? NSError {
                errorHandler("CREATE device: error \(e.domain) \(e.code): \(e.localizedDescription)")
                return
            }
            
            if response?.statusCode != 201 {
                errorHandler("CREATE device: bad response status code \(response?.statusCode)")
                return
            }
            
            let device = Device(json: json["devices"].arrayValue[0])
            success(device)
            
            return
        })
    }
    
    func delete(deviceId: Int, headers: [String: String] = APIDefaults.headers.bearer, success: (Void->Void), error errorHandler: (String->Void)) -> Request {
        
        return manager.request(.DELETE, "\(StepicApplicationsInfo.apiURL)/devices/\(deviceId)", headers: headers).response(completionHandler: {
            _, response, data, error in
            
            if let e = error {
                errorHandler("DESTROY device: error \(e.domain) \(e.code): \(e.localizedDescription)")
                return
            }
            
            if response?.statusCode != 204 && response?.statusCode != 404 {
                errorHandler("DESTROY device: bad response status code \(response?.statusCode)")
                return
            }
            
            success()
            
            return
        })
    }
    
    func retrieve(deviceId: Int, headers: [String: String] = APIDefaults.headers.bearer, success: (Device->Void), error errorHandler: (String-> Void)) -> Request {
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/devices/\(deviceId)", headers: headers).responseSwiftyJSON({
            _, response, json, error in
            
            if let e = error as? NSError {
                errorHandler("RETRIEVE device: error \(e.domain) \(e.code): \(e.localizedDescription)")
                return
            }
            
            if response?.statusCode != 200 {
                errorHandler("RETRIEVE device: bad response status code \(response?.statusCode)")
                return
            }
            
            let device = Device(json: json["devices"].arrayValue[0])
            success(device)
            
            return
        })
    }
}
