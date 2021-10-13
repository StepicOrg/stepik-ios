import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CourseBenefitByMonthsAPI: APIEndpoint {
    override var name: String { "course-benefit-by-months" }

    private let courseBenefitByMonthsPersistenceService: CourseBenefitByMonthsPersistenceServiceProtocol

    init(
        courseBenefitByMonthsPersistenceService: CourseBenefitByMonthsPersistenceServiceProtocol = CourseBenefitByMonthsPersistenceService()
    ) {
        self.courseBenefitByMonthsPersistenceService = courseBenefitByMonthsPersistenceService
        super.init()
    }

    func retrieve(courseID: Course.IdType, page: Int = 1) -> Promise<([CourseBenefitByMonth], Meta)> {
        let params: Parameters = [
            "page": page,
            "course": courseID
        ]

        return self.courseBenefitByMonthsPersistenceService.fetch(courseID: courseID).then {
            cachedCourseBenefitByMonths -> Promise<([CourseBenefitByMonth], Meta)> in
            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                params: params,
                updatingObjects: cachedCourseBenefitByMonths,
                withManager: self.manager
            )
        }
    }
}
