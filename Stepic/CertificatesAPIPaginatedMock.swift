//
//  CertificatesAPIPaginatedMock.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CertificatesAPIPaginatedMock: CertificatesAPI {

    var reportErrorOnNextRequest = true

    @discardableResult override func retrieve(userId: Int, page: Int, headers: [String : String], success: @escaping (Meta, [Certificate]) -> Void, error errorHandler: @escaping (NetworkError) -> Void) -> Request? {

        DispatchQueue.global(qos: .userInitiated).async {
            switch page {
            case 1...4:
                let start = page * 10
                let end = page * 10 + 9
                let certificates: [Certificate] = (start...end).map {
                    let cert = Certificate()
                    cert.id = $0
                    cert.grade = $0
                    cert.courseId = 191
                    cert.type = .distinction
                    return cert
                }

                let hasNext = page < 4 ? true : false
                let meta = Meta(hasNext: hasNext, hasPrev: false, page: page)
                success(meta, certificates)
                break
            default:
                break
            }
        }

        return nil

    }
}
