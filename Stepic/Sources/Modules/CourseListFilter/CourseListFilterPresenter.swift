import UIKit

protocol CourseListFilterPresenterProtocol {
    func presentCourseListFilters(response: CourseListFilter.CourseListFilterLoad.Response)
}

final class CourseListFilterPresenter: CourseListFilterPresenterProtocol {
    weak var viewController: CourseListFilterViewControllerProtocol?

    func presentCourseListFilters(response: CourseListFilter.CourseListFilterLoad.Response) {
        self.viewController?.displayCourseListFilters(
            viewModel: .init(
                viewModel: CourseListFilterViewModel(
                    courseLanguage: response.data.courseLanguage,
                    isPaid: response.data.isPaid,
                    withCertificate: response.data.withCertificate
                )
            )
        )
    }
}
