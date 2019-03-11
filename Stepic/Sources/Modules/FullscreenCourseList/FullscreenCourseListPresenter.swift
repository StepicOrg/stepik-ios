import UIKit

protocol FullscreenCourseListPresenterProtocol {
    func presentCourseInfo(response: FullscreenCourseList.CourseInfoPresentation.Response)
    func presentCourseSyllabus(response: FullscreenCourseList.CourseSyllabusPresentation.Response)
    func presentLastStep(response: FullscreenCourseList.LastStepPresentation.Response)
    func presentAuthorization(response: FullscreenCourseList.PresentAuthorization.Response)
    func presentPlaceholder(response: FullscreenCourseList.PresentPlaceholder.Response)
}

final class FullscreenCourseListPresenter: FullscreenCourseListPresenterProtocol {
    weak var viewController: FullscreenCourseListViewControllerProtocol?

    func presentCourseInfo(response: FullscreenCourseList.CourseInfoPresentation.Response) {
        self.viewController?.displayCourseInfo(viewModel: .init(courseID: response.course.id))
    }

    func presentCourseSyllabus(response: FullscreenCourseList.CourseSyllabusPresentation.Response) {
        self.viewController?.displayCourseSyllabus(viewModel: .init(courseID: response.course.id))
    }

    func presentLastStep(response: FullscreenCourseList.LastStepPresentation.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive
            )
        )
    }

    func presentAuthorization(response: FullscreenCourseList.PresentAuthorization.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }

    func presentPlaceholder(response: FullscreenCourseList.PresentPlaceholder.Response) {
        self.viewController?.displayPlaceholder(viewModel: .init(state: response.state))
    }
}
