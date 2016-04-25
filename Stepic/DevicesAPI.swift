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
    
    func create(device: Device, success: (Device->Void), error errorHandler: (String->Void)) -> Request {
        let headers = APIDefaults.headers.create
        let params = ["device": device.getJSON()]
        return Alamofire.request(.POST, "\(StepicApplicationsInfo.apiURL)/devices", parameters: params, encoding: .JSON, headers: headers).responseSwiftyJSON({
            _, response, json, error in
            
            if let e = error as? NSError {
                errorHandler("CREATE device: error \(e.domain) \(e.code): \(e.localizedDescription)")
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
}
