//
//  ProfilesAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class ProfilesAPI: APIEndpoint {
    override class var name: String { "profiles" }

    func retrieve(
        ids: [Int],
        existing: [Profile],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders
    ) -> Promise<[Profile]> {
        self.getObjectsByIds(ids: ids, updating: existing)
    }

    @available(*, deprecated, message: "Legacy: we want to pass existing")
    func retrieve(
        id: Int,
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders
    ) -> Promise<[Profile]> {
        self.getObjectsByIds(ids: [id], updating: Profile.fetchById(id) ?? [])
    }

    func update(_ profile: Profile) -> Promise<Profile> {
        self.update.request(
            requestEndpoint: Self.name,
            paramName: "profile",
            updatingObject: profile,
            withManager: self.manager
        )
    }
}
