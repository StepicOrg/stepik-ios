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

class CertificatesAPIPaginatedMock : CertificatesAPI {
    
    var hadError = false
    
    @discardableResult override func retrieve(userId: Int, page: Int, headers: [String : String], success: @escaping (Meta, [Certificate]) -> Void, error errorHandler: @escaping (RetrieveError) -> Void) -> Request? {
        
        switch page {
        case 1...2, 4:
            delay(1.0, closure: {
                let start = page * 10
                let end = page * 10 + 9
                let certificates : [Certificate] = (start...end).map{
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
            })
            break
        case 3:
            if !hadError {
                delay(1.5, closure: {
                    [weak self] in
                    errorHandler(.connectionError)
                    self?.hadError = true
                })
            } else {
                delay(1.0, closure: {
                    let start = page * 10
                    let end = page * 10 + 9
                    let certificates : [Certificate] = (start...end).map{
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
                })
            }
            break
        default:
            break
        }
        
        return nil

    }
}
