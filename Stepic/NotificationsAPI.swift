//
//  NotificationsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import SwiftyJSON

class NotificationsAPI {
    let name = "notifications"

    // TODO: it will be good to use APIEndpoint class here, but it doesn't allow empty ids list
    @discardableResult func retrieve(page: Int = 1, notificationType: NotificationType? = nil, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Meta, [Notification]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request {
        var parameters = [
            "page": "\(page)"
        ]

        if let notificationType = notificationType {
            parameters["type"] = notificationType.rawValue
        }

        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)", parameters: parameters, headers: headers).responseSwiftyJSON({ response in
            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response

            if let e = error as NSError? {
                print("RETRIEVE \(self.name): error \(e.domain) \(e.code): \(e.localizedDescription)")
                if e.code == -999 {
                    errorHandler(.cancelled)
                    return
                } else {
                    errorHandler(.connectionError)
                    return
                }
            }

            if response?.statusCode != 200 {
                print("RETRIEVE \(self.name)/: bad response status code \(String(describing: response?.statusCode))")
                errorHandler(.badStatus)
                return
            }

            let meta = Meta(json: json["meta"])
            let notifications = json["notifications"].arrayValue.map { Notification(json: $0) }
            success(meta, notifications)
        })
    }

    // TODO: maybe decomposite (like APIEndpoint)?
    @discardableResult func update(_ notification: Notification, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Notification) -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request? {
        let params: Parameters? = [
            "notification": notification.json as AnyObject
        ]
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)/\(notification.id)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({ response in
            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError(domain: "", code: -1, userInfo: nil)
                }
            } else {
                json = response.result.value!
            }
            let response = response.response

            if let e = error as NSError? {
                errorHandler("PUT notification: error \(e.domain) \(e.code): \(e.localizedDescription)")
                return
            }

            if response?.statusCode != 200 {
                errorHandler("PUT notification: bad response status code \(String(describing: response?.statusCode))")
                return
            }

            notification.update(json: json["notifications"].arrayValue[0])
            success(notification)

            return
        })
    }
}
