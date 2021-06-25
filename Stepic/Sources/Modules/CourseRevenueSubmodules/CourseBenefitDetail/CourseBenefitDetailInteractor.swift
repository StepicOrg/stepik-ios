import Foundation
import PromiseKit

protocol CourseBenefitDetailInteractorProtocol {
    func doCourseBenefitLoad(request: CourseBenefitDetail.CourseBenefitLoad.Request)
}

final class CourseBenefitDetailInteractor: CourseBenefitDetailInteractorProtocol {
    private let presenter: CourseBenefitDetailPresenterProtocol
    private let provider: CourseBenefitDetailProviderProtocol

    private let courseBenefitID: CourseBenefit.IdType
    private var currentCourseBenefit: CourseBenefit?

    init(
        presenter: CourseBenefitDetailPresenterProtocol,
        provider: CourseBenefitDetailProviderProtocol,
        courseBenefitID: CourseBenefit.IdType
    ) {
        self.presenter = presenter
        self.provider = provider
        self.courseBenefitID = courseBenefitID
    }

    func doCourseBenefitLoad(request: CourseBenefitDetail.CourseBenefitLoad.Request) {
        self.provider
            .fetchCourseBenefit()
            .compactMap { $0 }
            .done { courseBenefit in
                self.currentCourseBenefit = courseBenefit
                self.presenter.presentCourseBenefit(response: .init(result: .success(courseBenefit)))
            }.catch { _ in
                self.presenter.presentCourseBenefit(response: .init(result: .failure(Error.fetchFailed)))
            }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
