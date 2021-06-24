import UIKit

protocol CourseBenefitDetailPresenterProtocol {
    func presentSomeActionResult(response: CourseBenefitDetail.SomeAction.Response)
}

final class CourseBenefitDetailPresenter: CourseBenefitDetailPresenterProtocol {
    weak var viewController: CourseBenefitDetailViewControllerProtocol?

    func presentSomeActionResult(response: CourseBenefitDetail.SomeAction.Response) {}
}
