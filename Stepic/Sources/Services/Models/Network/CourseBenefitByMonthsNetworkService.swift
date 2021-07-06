import Foundation
import PromiseKit

protocol CourseBenefitByMonthsNetworkServiceProtocol: AnyObject {
    func fetch(courseID: Course.IdType, page: Int) -> Promise<([CourseBenefitByMonth], Meta)>
}

extension CourseBenefitByMonthsNetworkServiceProtocol {
    func fetch(courseID: Course.IdType) -> Promise<([CourseBenefitByMonth], Meta)> {
        self.fetch(courseID: courseID, page: 1)
    }
}

final class CourseBenefitByMonthsNetworkService: CourseBenefitByMonthsNetworkServiceProtocol {
    private let courseBenefitByMonthsAPI: CourseBenefitByMonthsAPI

    init(courseBenefitByMonthsAPI: CourseBenefitByMonthsAPI) {
        self.courseBenefitByMonthsAPI = courseBenefitByMonthsAPI
    }

    func fetch(courseID: Course.IdType, page: Int) -> Promise<([CourseBenefitByMonth], Meta)> {
        self.courseBenefitByMonthsAPI.retrieve(courseID: courseID, page: page)
    }
}
