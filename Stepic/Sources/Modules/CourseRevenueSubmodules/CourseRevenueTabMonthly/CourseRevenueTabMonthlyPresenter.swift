import UIKit

protocol CourseRevenueTabMonthlyPresenterProtocol {
    func presentSomeActionResult(response: CourseRevenueTabMonthly.SomeAction.Response)
}

final class CourseRevenueTabMonthlyPresenter: CourseRevenueTabMonthlyPresenterProtocol {
    weak var viewController: CourseRevenueTabMonthlyViewControllerProtocol?

    func presentSomeActionResult(response: CourseRevenueTabMonthly.SomeAction.Response) {}
}
