import Foundation
import PromiseKit

protocol CourseBenefitDetailProviderProtocol {
    func fetchCourseBenefit() -> Promise<CourseBenefit?>
}

final class CourseBenefitDetailProvider: CourseBenefitDetailProviderProtocol {
    private let courseBenefitID: CourseBenefit.IdType

    private let courseBenefitsPersistenceService: CourseBenefitsPersistenceServiceProtocol
    private let courseBenefitsNetworkService: CourseBenefitsNetworkServiceProtocol

    init(
        courseBenefitID: CourseBenefit.IdType,
        courseBenefitsPersistenceService: CourseBenefitsPersistenceServiceProtocol,
        courseBenefitsNetworkService: CourseBenefitsNetworkServiceProtocol
    ) {
        self.courseBenefitID = courseBenefitID
        self.courseBenefitsPersistenceService = courseBenefitsPersistenceService
        self.courseBenefitsNetworkService = courseBenefitsNetworkService
    }

    func fetchCourseBenefit() -> Promise<CourseBenefit?> {
        firstly { () -> Guarantee<CourseBenefit?> in
            self.courseBenefitsPersistenceService.fetch(id: self.courseBenefitID)
        }.then { cachedCourseBenefitOrNil -> Promise<CourseBenefit?> in
            if let cachedCourseBenefit = cachedCourseBenefitOrNil {
                return .value(cachedCourseBenefit)
            }
            return self.courseBenefitsNetworkService.fetch(ids: [self.courseBenefitID]).map(\.first)
        }
    }
}
