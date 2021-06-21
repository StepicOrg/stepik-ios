import UIKit

protocol CourseRevenuePresenterProtocol {
    func presentCourseRevenue(response: CourseRevenue.CourseRevenueLoad.Response)
}

final class CourseRevenuePresenter: CourseRevenuePresenterProtocol {
    weak var viewController: CourseRevenueViewControllerProtocol?

    func presentCourseRevenue(response: CourseRevenue.CourseRevenueLoad.Response) {}
}
