import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CourseBenefitsAPI: APIEndpoint {
    override var name: String { "course-benefits" }

    private let courseBenefitsPersistenceService: CourseBenefitsPersistenceServiceProtocol

    init(
        courseBenefitsPersistenceService: CourseBenefitsPersistenceServiceProtocol = CourseBenefitsPersistenceService()
    ) {
        self.courseBenefitsPersistenceService = courseBenefitsPersistenceService
        super.init()
    }

    func retrieve(courseID: Course.IdType? = nil, page: Int = 1) -> Promise<([CourseBenefit], Meta)> {
        var params: Parameters = ["page": page]

        if let courseID = courseID {
            params["course"] = courseID
        }

        return firstly { () -> Guarantee<[CourseBenefit]> in
            if let courseID = courseID {
                return self.courseBenefitsPersistenceService.fetch(courseID: courseID)
            } else {
                return self.courseBenefitsPersistenceService.fetchAll()
            }
        }.then { cachedCourseBenefits -> Promise<([CourseBenefit], Meta)> in
            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                params: params,
                updatingObjects: cachedCourseBenefits,
                withManager: self.manager
            )
        }
    }
}