import UIKit

protocol CourseBenefitDetailPresenterProtocol {
    func presentCourseBenefit(response: CourseBenefitDetail.CourseBenefitLoad.Response)
}

final class CourseBenefitDetailPresenter: CourseBenefitDetailPresenterProtocol {
    weak var viewController: CourseBenefitDetailViewControllerProtocol?

    func presentCourseBenefit(response: CourseBenefitDetail.CourseBenefitLoad.Response) {}
}
