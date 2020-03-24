//
//  EmailAddressesAPI.swift
//  Stepic
//
//  Created by Ivan Magda on 10/9/19.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class EmailAddressesAPI: APIEndpoint {
    override var name: String { "email-addresses" }

    /// Get email addresses by ids.
    func retrieve(ids: [EmailAddress.IdType], page: Int = 1) -> Promise<([EmailAddress], Meta)> {
        Promise { seal in
            let parameters: Parameters = [
                "ids": ids,
                "page": page
            ]

            EmailAddress.fetchAsync(ids: ids).then {
                cachedEmailAddresses -> Promise<([EmailAddress], Meta, JSON)> in
                self.retrieve.request(
                    requestEndpoint: self.name,
                    paramName: self.name,
                    params: parameters,
                    updatingObjects: cachedEmailAddresses,
                    withManager: self.manager
                )
            }.done { emailAddresses, meta, _ in
                seal.fulfill((emailAddresses, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
