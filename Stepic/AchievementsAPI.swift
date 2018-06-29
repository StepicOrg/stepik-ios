//
//  AchievementsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

class AchievementsAPI: APIEndpoint {
    override var name: String { return "achievements" }

    func retrieve(kind: String? = nil, page: Int = 1) -> Promise<([Achievement], Meta)> {
        return Promise { fulfill, reject in
            var params = Parameters()
            if let kind = kind {
                params["kind"] = kind
            }
            params["page"] = page

            retrieve.request(requestEndpoint: name, paramName: name, params: params, updatingObjects: [], withManager: manager).then { achievements, meta -> Void in
                fulfill((achievements, meta))
            }.catch { error in
                reject(error)
            }
        }
    }
}
