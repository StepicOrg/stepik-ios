import UIKit

protocol CourseSearchPresenterProtocol {
    func presentCourseContent(response: CourseSearch.CourseContentLoad.Response)
}

final class CourseSearchPresenter: CourseSearchPresenterProtocol {
    weak var viewController: CourseSearchViewControllerProtocol?

    func presentCourseContent(response: CourseSearch.CourseContentLoad.Response) {}
}
