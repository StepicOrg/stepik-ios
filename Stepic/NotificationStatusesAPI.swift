//
//  NotificationsStatusesAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

final class NotificationStatusesAPI: APIEndpoint {
    override var name: String { return "notification-statuses" }

    func retrieve() -> Promise<NotificationsStatus> {
        return Promise { seal in
            retrieve.request(requestEndpoint: "notification-statuses", paramName: "notification-statuses", params: Parameters(), updatingObjects: [NotificationsStatus](), withManager: manager).done {
                notificationStatuses, _, _ in
                guard let status = notificationStatuses.first else {
                    seal.reject(ParsingError.badData)
                    return
                }
                seal.fulfill(status)
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }
}
