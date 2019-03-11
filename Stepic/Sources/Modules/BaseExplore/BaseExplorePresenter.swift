import UIKit

protocol BaseExplorePresenterProtocol {
    func presentFullscreenCourseList(response: BaseExplore.FullscreenCourseListModulePresentation.Response)
    func presentCourseInfo(response: BaseExplore.CourseInfoPresentation.Response)
    func presentCourseSyllabus(response: BaseExplore.CourseSyllabusPresentation.Response)
    func presentLastStep(response: BaseExplore.LastStepPresentation.Response)
    func presentAuthorization(response: BaseExplore.AuthorizationPresentation.Response)
}

class BaseExplorePresenter: BaseExplorePresenterProtocol {
    weak var viewController: BaseExploreViewControllerProtocol?

    func presentFullscreenCourseList(response: BaseExplore.FullscreenCourseListModulePresentation.Response) {
        self.viewController?.displayFullscreenCourseList(
            viewModel: .init(
                presentationDescription: response.presentationDescription,
                courseListType: response.courseListType
            )
        )
    }

    func presentCourseInfo(response: BaseExplore.CourseInfoPresentation.Response) {
        self.viewController?.displayCourseInfo(viewModel: .init(courseID: response.course.id))
    }

    func presentCourseSyllabus(response: BaseExplore.CourseSyllabusPresentation.Response) {
        self.viewController?.displayCourseSyllabus(viewModel: .init(courseID: response.course.id))
    }

    func presentLastStep(response: BaseExplore.LastStepPresentation.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive
            )
        )
    }

    func presentAuthorization(response: BaseExplore.AuthorizationPresentation.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }
}
