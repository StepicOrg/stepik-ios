//
//  EnrollmentsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 09.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import PromiseKit

class EnrollmentsAPI: APIEndpoint {
    override var name: String { return "enrollments" }

    func joinCourse(_ course: Course, delete: Bool = false) -> Promise<Void> {
        return Promise { fulfill, reject in
            joinCourse(course, delete: delete, success: {
                fulfill(())
            }, error: { _ in
                reject(EnrollmentsAPIError.joinCourseFailed)
            })
        }
    }

    func delete(courseId: Int) -> Promise<Void> {
        return delete.request(requestEndpoint: "enrollments", deletingId: courseId, withManager: manager)
    }
    
    @discardableResult func joinCourse(_ course: Course, delete: Bool = false, success : @escaping () -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        let headers: [String : String] = AuthInfo.shared.initialHTTPHeaders

        let params: Parameters = [
            "enrollment": [
                "course": "\(course.id)"
            ]
        ]

        if !delete {
            return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({
                response in

                var error = response.result.error
                var json : JSON = [:]
                if response.result.value == nil {
                    if error == nil {
                        error = NSError()
                    }
                } else {
                    json = response.result.value!
                }
                let response = response.response

                if let r = response {
                    if r.statusCode >= 200 && r.statusCode <= 299 {
                        if let courseJSON = json["courses"].array?[0] {
                            course.update(json: courseJSON)
                        }
                        success()
                    } else {
                        let s = NSLocalizedString("TryJoinFromWeb", comment: "")
                        errorHandler(s)
                    }
                } else {
                    let s = NSLocalizedString("Error", comment: "")
                    errorHandler(s)
                }
            })
        } else {
            return Alamofire.request("\(StepicApplicationsInfo.apiURL)/enrollments/\(course.id)", method: .delete, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
                response in

                var error = response.result.error
                //                var json : JSON = [:]
                if response.result.value == nil {
                    if error == nil {
                        error = NSError()
                    }
                } else {
                    //                    json = response.result.value!
                }
                let response = response.response

                if let r = response {
                    if r.statusCode >= 200 && r.statusCode <= 299 {
                        success()
                        return
                    }
                }

                let s = NSLocalizedString("Error", comment: "")
                errorHandler(s)
            })

        }

    }
}

enum EnrollmentsAPIError: Error {
    case joinCourseFailed
}
