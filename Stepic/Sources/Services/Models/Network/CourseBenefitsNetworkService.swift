import Foundation
import PromiseKit

protocol CourseBenefitsNetworkServiceProtocol: AnyObject {
    func fetch(courseID: Course.IdType, page: Int) -> Promise<([CourseBenefit], Meta)>
    func fetch(page: Int) -> Promise<([CourseBenefit], Meta)>
}

extension CourseBenefitsNetworkServiceProtocol {
    func fetch(courseID: Course.IdType) -> Promise<([CourseBenefit], Meta)> {
        self.fetch(courseID: courseID, page: 1)
    }

    func fetch() -> Promise<([CourseBenefit], Meta)> {
        self.fetch(page: 1)
    }
}

final class CourseBenefitsNetworkService: CourseBenefitsNetworkServiceProtocol {
    private let courseBenefitsAPI: CourseBenefitsAPI

    init(courseBenefitsAPI: CourseBenefitsAPI) {
        self.courseBenefitsAPI = courseBenefitsAPI
    }

    func fetch(courseID: Course.IdType, page: Int) -> Promise<([CourseBenefit], Meta)> {
        self.courseBenefitsAPI.retrieve(courseID: courseID, page: page)
    }

    func fetch(page: Int) -> Promise<([CourseBenefit], Meta)> {
        self.courseBenefitsAPI.retrieve(courseID: nil, page: page)
    }
}
