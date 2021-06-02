import UIKit

protocol NewProfileCreatedCoursesPresenterProtocol {
    func presentCourses(response: NewProfileCreatedCourses.CoursesLoad.Response)
    func presentCourseInfo(response: NewProfileCreatedCourses.CourseInfoPresentation.Response)
    func presentCourseSyllabus(response: NewProfileCreatedCourses.CourseSyllabusPresentation.Response)
    func presentLastStep(response: NewProfileCreatedCourses.LastStepPresentation.Response)
    func presentAuthorization(response: NewProfileCreatedCourses.PresentAuthorization.Response)
    func presentError(response: NewProfileCreatedCourses.PresentError.Response)
}

final class NewProfileCreatedCoursesPresenter: NewProfileCreatedCoursesPresenterProtocol {
    weak var viewController: NewProfileCreatedCoursesViewControllerProtocol?

    func presentCourses(response: NewProfileCreatedCourses.CoursesLoad.Response) {
        self.viewController?.displayCourses(viewModel: .init(teacherID: response.teacherID))
    }

    func presentCourseInfo(response: NewProfileCreatedCourses.CourseInfoPresentation.Response) {
        self.viewController?.displayCourseInfo(
            viewModel: .init(courseID: response.course.id, courseViewSource: response.courseViewSource)
        )
    }

    func presentCourseSyllabus(response: NewProfileCreatedCourses.CourseSyllabusPresentation.Response) {
        self.viewController?.displayCourseSyllabus(
            viewModel: .init(courseID: response.course.id, courseViewSource: response.courseViewSource)
        )
    }

    func presentLastStep(response: NewProfileCreatedCourses.LastStepPresentation.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive,
                courseContinueSource: response.courseContinueSource,
                courseViewSource: response.courseViewSource
            )
        )
    }

    func presentAuthorization(response: NewProfileCreatedCourses.PresentAuthorization.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }

    func presentError(response: NewProfileCreatedCourses.PresentError.Response) {
        self.viewController?.displayError(viewModel: .init())
    }
}
