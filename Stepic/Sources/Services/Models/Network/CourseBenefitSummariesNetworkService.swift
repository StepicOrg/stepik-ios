import Foundation
import PromiseKit

protocol CourseBenefitSummariesNetworkServiceProtocol: AnyObject {
    func fetch(id: CourseBenefitSummary.IdType) -> Promise<([CourseBenefitSummary], Meta)>
}

extension CourseBenefitSummariesNetworkServiceProtocol {
    func fetch(id: CourseBenefitSummary.IdType) -> Promise<CourseBenefitSummary?> {
        self.fetch(id: id).map(\.0.first)
    }
}

final class CourseBenefitSummariesNetworkService: CourseBenefitSummariesNetworkServiceProtocol {
    private let courseBenefitSummariesAPI: CourseBenefitSummariesAPI

    init(courseBenefitSummariesAPI: CourseBenefitSummariesAPI) {
        self.courseBenefitSummariesAPI = courseBenefitSummariesAPI
    }

    func fetch(id: CourseBenefitSummary.IdType) -> Promise<([CourseBenefitSummary], Meta)> {
        self.courseBenefitSummariesAPI.retrieve(id: id)
    }
}
