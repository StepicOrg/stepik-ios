import UIKit

protocol NewProfileCreatedCoursesPresenterProtocol {
    func presentCourses(response: NewProfileCreatedCourses.CoursesLoad.Response)
}

final class NewProfileCreatedCoursesPresenter: NewProfileCreatedCoursesPresenterProtocol {
    weak var viewController: NewProfileCreatedCoursesViewControllerProtocol?

    func presentCourses(response: NewProfileCreatedCourses.CoursesLoad.Response) {
        self.viewController?.displayCourses(viewModel: .init(teacherID: response.teacherID))
    }
}
