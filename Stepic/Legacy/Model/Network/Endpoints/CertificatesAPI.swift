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
    override var name: String { "certificates" }

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
            requestEndpoint: self.name,
            paramName: self.name,
            params: params,
            withManager: manager
        )
    }

    //Cannot move it to extension cause it is used in tests
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func retrieve(
        userId: Int,
        page: Int = 1,
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping (Meta, [Certificate]) -> Void,
        error errorHandler: @escaping (NetworkError) -> Void
    ) -> Request? {
        self.retrieve(userID: userId, page: page).done { certificates, meta in
            success(meta, certificates)
        }.catch { error in
            errorHandler(NetworkError(error: error))
        }
        return nil
    }

    enum Order: String {
        case idDesc = "-id"
    }
}
