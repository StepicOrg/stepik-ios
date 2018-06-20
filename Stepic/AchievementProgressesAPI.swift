//
//  AchievementProgressesAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

class AchievementProgressesAPI: APIEndpoint {
    override var name: String { return "achievement-progresses" }

    func retrieve(user: Int, kind: String? = nil, sortByObtainDateDesc: Bool = false, page: Int = 1) -> Promise<([AchievementProgress], Meta)> {
        return Promise { fulfill, reject in
            var params = Parameters()
            if let kind = kind {
                params["kind"] = kind
            }
            params["user"] = user
            params["page"] = page
            if sortByObtainDateDesc {
                params["order"] = "-obtain_date"
            }

            retrieve.request(requestEndpoint: name, paramName: name, params: params, updatingObjects: [], withManager: manager).then { progresses, meta -> Void in
                fulfill((progresses, meta))
            }.catch { error in
                reject(error)
            }
        }
    }
}
