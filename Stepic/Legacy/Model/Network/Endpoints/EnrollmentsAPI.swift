//
//  EnrollmentsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 09.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class EnrollmentsAPI: APIEndpoint {
    override var name: String { "enrollments" }

    func delete(courseId: Int) -> Promise<Void> {
        self.delete.request(requestEndpoint: self.name, deletingId: courseId, withManager: manager)
    }
}

extension EnrollmentsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    func joinCourse(_ course: Course, delete: Bool = false) -> Promise<Void> {
        Promise { seal in
            joinCourse(course, delete: delete, success: {
                seal.fulfill(())
            }, error: { _ in
                seal.reject(EnrollmentsAPIError.joinCourseFailed)
            })
        }
    }

    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func joinCourse(
        _ course: Course,
        delete: Bool = false,
        success: @escaping () -> Void,
        error errorHandler: @escaping (String) -> Void
    ) -> Request? {
        let headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders
        let params: Parameters = [
            "enrollment": [
                "course": "\(course.id)"
            ]
        ]

        if !delete {
            return self.manager.request(
                "\(StepikApplicationsInfo.apiURL)/\(self.name)",
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: headers
            ).validate().responseSwiftyJSON { response in
                switch response.result {
                case .success(let json):
                    if let courseJSON = json["courses"].array?[0] {
                        course.update(json: courseJSON)
                    }
                    success()
                case .failure:
                    errorHandler(NSLocalizedString("Error", comment: ""))
                }
            }
        } else {
            return self.manager.request(
                "\(StepikApplicationsInfo.apiURL)/enrollments/\(course.id)",
                method: .delete,
                parameters: params,
                encoding: URLEncoding.default,
                headers: headers
            ).validate().responseSwiftyJSON { response in
                switch response.result {
                case .success:
                    success()
                case .failure:
                    errorHandler(NSLocalizedString("Error", comment: ""))
                }
            }
        }
    }
}

@available(*, deprecated, message: "Legacy error")
enum EnrollmentsAPIError: Error {
    case joinCourseFailed
}
