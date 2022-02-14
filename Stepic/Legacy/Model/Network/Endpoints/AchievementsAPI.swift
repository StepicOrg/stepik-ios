//
//  AchievementsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

final class AchievementsAPI: APIEndpoint {
    override class var name: String { "achievements" }

    func retrieve(kind: String? = nil, page: Int = 1) -> Promise<([Achievement], Meta)> {
        Promise { seal in
            var params = Parameters()
            if let kind = kind {
                params["kind"] = kind
            }
            params["page"] = page

            self.retrieve.request(
                requestEndpoint: Self.name,
                paramName: Self.name,
                params: params,
                updatingObjects: [],
                withManager: self.manager
            ).done { achievements, meta in
                seal.fulfill((achievements, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
