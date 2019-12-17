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

    func retrieve(userId: Int, page: Int = 1) -> Promise<([Certificate], Meta)> {
        let params: Parameters = [
            "user": userId,
            "page": page
        ]

        return retrieve.requestWithFetching(requestEndpoint: "certificates", paramName: "certificates", params: params, withManager: manager)
    }

    //Cannot move it to extension cause it is used in tests
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func retrieve(userId: Int, page: Int = 1, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Meta, [Certificate]) -> Void, error errorHandler: @escaping (NetworkError) -> Void) -> Request? {
        retrieve(userId: userId, page: page).done {
            certificates, meta in
            success(meta, certificates)
        }.catch {
            error in
            errorHandler(NetworkError(error: error))
        }
        return nil
    }
}
