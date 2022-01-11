import Foundation
import PromiseKit

protocol CourseBenefitDetailInteractorProtocol {
    func doCourseBenefitLoad(request: CourseBenefitDetail.CourseBenefitLoad.Request)
    func doCourseInfoPresentation(request: CourseBenefitDetail.CourseInfoPresentation.Request)
    func doBuyerProfilePresentation(request: CourseBenefitDetail.BuyerProfilePresentation.Request)
}

final class CourseBenefitDetailInteractor: CourseBenefitDetailInteractorProtocol {
    weak var moduleOutput: CourseBenefitDetailOutputProtocol?

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

    func doCourseInfoPresentation(request: CourseBenefitDetail.CourseInfoPresentation.Request) {
        if let currentCourseBenefit = self.currentCourseBenefit {
            self.moduleOutput?.handleCourseBenefitDetailDidRequestPresentCourseInfo(
                courseID: currentCourseBenefit.courseID
            )
        }
    }

    func doBuyerProfilePresentation(request: CourseBenefitDetail.BuyerProfilePresentation.Request) {
        if let buyerID = self.currentCourseBenefit?.buyerID {
            self.moduleOutput?.handleCourseBenefitDetailDidRequestPresentUser(userID: buyerID)
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
