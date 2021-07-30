import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CourseBenefitSummariesAPI: APIEndpoint {
    override var name: String { "course-benefit-summaries" }

    private let courseBenefitSummariesPersistenceService: CourseBenefitSummariesPersistenceServiceProtocol

    init(
        courseBenefitSummariesPersistenceService: CourseBenefitSummariesPersistenceServiceProtocol = CourseBenefitSummariesPersistenceService()
    ) {
        self.courseBenefitSummariesPersistenceService = courseBenefitSummariesPersistenceService
        super.init()
    }

    func retrieve(id: CourseBenefitSummary.IdType) -> Promise<([CourseBenefitSummary], Meta)> {
        firstly { () -> Guarantee<[CourseBenefitSummary]> in
            self.courseBenefitSummariesPersistenceService.fetch(id: id).map { $0 != nil ? [$0!] : [] }
        }.then { cachedCourseBenefitSummaries -> Promise<([CourseBenefitSummary], Meta)> in
            self.retrieve.request(
                requestEndpoint: "\(self.name)/\(id)",
                paramName: self.name,
                params: [:],
                updatingObjects: cachedCourseBenefitSummaries,
                withManager: self.manager
            )
        }
    }
}
