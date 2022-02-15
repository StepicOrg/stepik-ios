import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CoursePaymentsAPI: APIEndpoint {
    override class var name: String { "course-payments" }

    func retrieve(courseID: Course.IdType) -> Promise<([CoursePayment], Meta)> {
        let params: Parameters = [
            "order": "-id",
            CoursePayment.JSONKey.course.rawValue: courseID
        ]

        return self.retrieve.request(
            requestEndpoint: Self.name,
            paramName: Self.name,
            params: params,
            withManager: self.manager
        )
    }

    func create(_ coursePayment: CoursePayment) -> Promise<CoursePayment> {
        self.create.request(
            requestEndpoint: Self.name,
            paramName: "course-payment",
            creatingObject: coursePayment,
            withManager: self.manager
        )
    }
}
