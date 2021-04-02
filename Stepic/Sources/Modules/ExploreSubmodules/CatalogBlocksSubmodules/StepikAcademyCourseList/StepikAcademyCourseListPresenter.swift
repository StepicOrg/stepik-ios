import UIKit

protocol StepikAcademyCourseListPresenterProtocol {
    func presentSomeActionResult(response: StepikAcademyCourseList.SomeAction.Response)
}

final class StepikAcademyCourseListPresenter: StepikAcademyCourseListPresenterProtocol {
    weak var viewController: StepikAcademyCourseListViewControllerProtocol?

    func presentSomeActionResult(response: StepikAcademyCourseList.SomeAction.Response) {}
}
