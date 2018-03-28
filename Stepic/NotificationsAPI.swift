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
import PromiseKit

class NotificationsAPI: APIEndpoint {
    override var name: String { return "notifications" }

    func retrieve(page: Int = 1, notificationType: NotificationType? = nil, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<( [Notification], Meta)> {

        var parameters = [
            "page": "\(page)"
        ]

        if let notificationType = notificationType {
            parameters["type"] = notificationType.rawValue
        }

        return retrieve.requestWithFetching(requestEndpoint: "notifications", paramName: "notifications", params: parameters, withManager: manager)
    }

//    func retrieve(page: Int = 1, notificationType: NotificationType? = nil, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<(Meta, [Notification])> {
//
//        return Promise { fulfill, reject in
//            var parameters = [
//                "page": "\(page)"
//            ]
//
//            if let notificationType = notificationType {
//                parameters["type"] = notificationType.rawValue
//            }
//
//            manager.request("\(StepicApplicationsInfo.apiURL)/\(self.name)", parameters: parameters, headers: headers).responseSwiftyJSON { response in
//                switch response.result {
//                case .failure(let error):
//                    reject(RetrieveError(error: error))
//                case .success(let json):
//                    let savedNotifications = Notification.fetch(json["notifications"].arrayValue.map { $0["id"].intValue })
//                    var newNotifications: [Notification] = []
//                    for objectJSON in json["notifications"].arrayValue {
//                        let existing = savedNotifications.filter { obj in obj.hasEqualId(json: objectJSON) }
//
//                        switch existing.count {
//                        case 0:
//                            newNotifications.append(Notification(json: objectJSON))
//                        default:
//                            let obj = existing[0]
//                            obj.update(json: objectJSON)
//                            newNotifications.append(obj)
//                        }
//                    }
//
//                    CoreDataHelper.instance.save()
//
//                    let meta = Meta(json: json["meta"])
//                    fulfill((meta, newNotifications))
//                }
//            }
//        }
//    }

    func update(_ notification: Notification) -> Promise<Notification> {
        return update.request(requestEndpoint: "notifications", paramName: "notification", updatingObject: notification, withManager: manager)
    }

    func markAllAsRead(headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<()> {
        return Promise { fulfill, reject in
            manager.request("\(StepicApplicationsInfo.apiURL)/\(name)/mark-as-read", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    reject(error)
                case .success(_):
                    if response.response?.statusCode != 204 {
                        reject(NotificationsAPIError.invalidStatus)
                    } else {
                        fulfill(())
                    }
                }
            }
        }
    }
}

// TODO: replace this class by generic error class
enum NotificationsAPIError: Error {
    case invalidStatus
}
