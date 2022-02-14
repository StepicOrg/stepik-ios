import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CourseBeneficiariesAPI: APIEndpoint {
    override class var name: String { "course-beneficiaries" }

    private let courseBeneficiariesPersistenceService: CourseBeneficiariesPersistenceServiceProtocol

    init(
        courseBeneficiariesPersistenceService: CourseBeneficiariesPersistenceServiceProtocol = CourseBeneficiariesPersistenceService()
    ) {
        self.courseBeneficiariesPersistenceService = courseBeneficiariesPersistenceService
        super.init()
    }

    func retrieve(
        courseID: Course.IdType,
        userID: User.IdType,
        page: Int = 1
    ) -> Promise<([CourseBeneficiary], Meta)> {
        let params: Parameters = [
            "course": courseID,
            "user": userID,
            "page": page
        ]

        return self.courseBeneficiariesPersistenceService.fetch(courseID: courseID, userID: userID).then {
            cachedCourseBeneficiaries -> Promise<([CourseBeneficiary], Meta)> in
            self.retrieve.request(
                requestEndpoint: Self.name,
                paramName: Self.name,
                params: params,
                updatingObjects: cachedCourseBeneficiaries,
                withManager: self.manager
            )
        }
    }
}
