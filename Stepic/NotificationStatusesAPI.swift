//
//  NotificationStatusesAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

class NotificationStatusesAPI: APIEndpoint {
    override var name: String { return "notification-statuses" }
    
    func retrieve() -> Promise<NotificationStatuses> {
        return Promise { fulfill, reject in
            manager.request("\(StepicApplicationsInfo.apiURL)/\(name)", parameters: nil, headers: AuthInfo.shared.initialHTTPHeaders).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    reject(RetrieveError(error: error))
                case .success(let json):
                    let ns = NotificationStatuses(json: json["notification-statuses"].arrayValue[0])
                    fulfill(ns)
                }
            }
        }
    }
}
