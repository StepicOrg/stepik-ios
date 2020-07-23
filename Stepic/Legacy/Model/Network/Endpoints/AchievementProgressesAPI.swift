//
//  AchievementProgressesAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

final class AchievementProgressesAPI: APIEndpoint {
    override var name: String { "achievement-progresses" }

    func retrieve(
        userID: Int,
        kind: String? = nil,
        order: Order? = nil,
        page: Int = 1
    ) -> Promise<([AchievementProgress], Meta)> {
        Promise { seal in
            var params = Parameters()

            params["user"] = userID
            params["page"] = page

            if let kind = kind {
                params["kind"] = kind
            }

            if let order = order {
                params["order"] = order.rawValue
            }

            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                params: params,
                updatingObjects: [],
                withManager: self.manager
            ).done { progresses, meta in
                seal.fulfill((progresses, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    enum Order: String {
        case obtainDateDesc = "-obtain_date"
    }
}
