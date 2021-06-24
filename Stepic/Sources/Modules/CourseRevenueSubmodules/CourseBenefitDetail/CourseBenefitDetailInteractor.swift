import Foundation
import PromiseKit

protocol CourseBenefitDetailInteractorProtocol {
    func doCourseBenefitLoad(request: CourseBenefitDetail.CourseBenefitLoad.Request)
}

final class CourseBenefitDetailInteractor: CourseBenefitDetailInteractorProtocol {
    private let presenter: CourseBenefitDetailPresenterProtocol
    private let provider: CourseBenefitDetailProviderProtocol

    private let courseBenefitID: CourseBenefit.IdType

    init(
        presenter: CourseBenefitDetailPresenterProtocol,
        provider: CourseBenefitDetailProviderProtocol,
        courseBenefitID: CourseBenefit.IdType
    ) {
        self.presenter = presenter
        self.provider = provider
        self.courseBenefitID = courseBenefitID
    }

    func doCourseBenefitLoad(request: CourseBenefitDetail.CourseBenefitLoad.Request) {}
}
