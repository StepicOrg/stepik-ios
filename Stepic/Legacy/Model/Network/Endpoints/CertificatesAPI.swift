//
//  CertificatesAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CertificatesAPI: APIEndpoint {
    override class var name: String { "certificates" }

    func retrieve(
        userID: User.IdType,
        courseID: Course.IdType? = nil,
        page: Int = 1,
        order: Order? = nil
    ) -> Promise<([Certificate], Meta)> {
        var params: Parameters = [
            "user": userID,
            "page": page
        ]

        if let courseID = courseID {
            params["course"] = courseID
        }

        if let order = order {
            params["order"] = order.rawValue
        }

        return self.retrieve.requestWithFetching(
            requestEndpoint: Self.name,
            paramName: Self.name,
            params: params,
            withManager: manager
        )
    }

    func update(_ certificate: Certificate) -> Promise<Certificate> {
        self.update.request(
            requestEndpoint: Self.name,
            paramName: "certificate",
            updatingObject: certificate,
            withManager: self.manager
        )
    }

    enum Order: String {
        case idDesc = "-id"
    }
}
