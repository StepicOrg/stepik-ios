//
//  CertificatesAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CertificatesAPI: APIEndpoint {
    override var name: String { return "certificates" }

    @discardableResult func retrieve(userId: Int, page: Int = 1, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Meta, [Certificate]) -> Void, error errorHandler: @escaping (RetrieveError) -> Void) -> Request? {

        let params: Parameters = [
            "user": userId,
            "page": page
        ]

        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)", parameters: params, headers: headers).responseSwiftyJSON({
                response in

                var error = response.result.error
                var json: JSON = [:]
                if response.result.value == nil {
                    if error == nil {
                        error = NSError()
                    }
                } else {
                    json = response.result.value!
                }
                let response = response.response

                if let e = error as NSError? {
                    print("RETRIEVE certificates/\(userId): error \(e.domain) \(e.code): \(e.localizedDescription)")
                    errorHandler(.connectionError)
                    return
                }

                if response?.statusCode != 200 {
                    print("RETRIEVE certificates/\(userId): bad response status code \(String(describing: response?.statusCode))")
                    errorHandler(.badStatus)
                    return
                }

                let meta = Meta(json: json["meta"])

                //Collect all retrieved ids

                let ids = json["certificates"].arrayValue.flatMap {
                    $0["id"].int
                }

                //Fetch certificates data for all retrieved ids

                let existingCertificates = Certificate.fetch(ids, user: userId)

                //Update existing certificates & create new

                let res: [Certificate] = json["certificates"].arrayValue.map {
                    certificateJSON in
                    if let filtered = existingCertificates.filter({$0.hasEqualId(json: certificateJSON)}).first {
                        filtered.update(json: certificateJSON)
                        return filtered
                    } else {
                        return Certificate(json: certificateJSON)
                    }
                }

                //Return certificates

                success((meta, res))

                return
            }
        )
    }

}
