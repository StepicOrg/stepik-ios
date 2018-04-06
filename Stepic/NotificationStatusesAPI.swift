//
//  NotificationsStatusesAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

class NotificationStatusesAPI: APIEndpoint {
    override var name: String { return "notification-statuses" }

    func retrieve() -> Promise<NotificationsStatus> {
        return Promise { fulfill, reject in
            retrieve.request(requestEndpoint: "notification-statuses", paramName: "notification-statuses", params: Parameters(), updatingObjects: Array<NotificationsStatus>(), withManager: manager).then {
                notificationStatuses, _, _ -> Void in
                guard let status = notificationStatuses.first else {
                    reject(RetrieveError.parsingError)
                    return
                }
                fulfill(status)
            }.catch {
                error in
                reject(error)
            }
        }
    }
}
