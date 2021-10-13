import Foundation
import PromiseKit

protocol CourseBeneficiariesNetworkServiceProtocol: AnyObject {
    func fetch(courseID: Course.IdType, userID: User.IdType, page: Int) -> Promise<([CourseBeneficiary], Meta)>
}

extension CourseBeneficiariesNetworkServiceProtocol {
    func fetch(courseID: Course.IdType, userID: User.IdType) -> Promise<([CourseBeneficiary], Meta)> {
        self.fetch(courseID: courseID, userID: userID, page: 1)
    }

    func fetch(courseID: Course.IdType, userID: User.IdType, page: Int = 1) -> Promise<CourseBeneficiary?> {
        self.fetch(courseID: courseID, userID: userID, page: page).map(\.0.first)
    }
}

final class CourseBeneficiariesNetworkService: CourseBeneficiariesNetworkServiceProtocol {
    private let courseBeneficiariesAPI: CourseBeneficiariesAPI

    init(courseBeneficiariesAPI: CourseBeneficiariesAPI) {
        self.courseBeneficiariesAPI = courseBeneficiariesAPI
    }

    func fetch(courseID: Course.IdType, userID: User.IdType, page: Int) -> Promise<([CourseBeneficiary], Meta)> {
        self.courseBeneficiariesAPI.retrieve(courseID: courseID, userID: userID, page: page)
    }
}
