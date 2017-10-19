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

            let savedNotifications = Notification.fetch(json["notifications"].arrayValue.map { $0["id"].intValue })
            var newNotifications: [Notification] = []
            for objectJSON in json["notifications"].arrayValue {
                let existing = savedNotifications.filter { obj in obj.hasEqualId(json: objectJSON) }

                switch existing.count {
                case 0:
                    newNotifications.append(Notification(json: objectJSON))
                default:
                    let obj = existing[0]

                    let oldStatus = obj.status
                    let isUnreadFetched = objectJSON["is_unread"].boolValue
                    obj.update(json: objectJSON)

                    // Save read status
                    if oldStatus == .read && isUnreadFetched {
                        obj.status = .read
                    }
                    newNotifications.append(obj)
                }
            }

            CoreDataHelper.instance.save()

            let meta = Meta(json: json["meta"])
            success(meta, newNotifications)
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

            // Update notification, but save read status
            notification.update(json: json["notifications"].arrayValue[0])
            success(notification)

            return
        })
    }

    @discardableResult func markAllAsRead(headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (() -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request? {
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)/mark-as-read", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({ response in
            var error = response.result.error
            if response.result.value == nil {
                if error == nil {
                    error = NSError(domain: "", code: -1, userInfo: nil)
                }
            }
            let response = response.response

            if let e = error as NSError? {
                errorHandler("POST mark-as-read: error \(e.domain) \(e.code): \(e.localizedDescription)")
                return
            }

            if response?.statusCode != 204 {
                errorHandler("POST mark-as-read: bad response status code \(String(describing: response?.statusCode))")
                return
            }

            success()
            return
        })
    }
}
