import UIKit

protocol BaseExplorePresenterProtocol {
    func presentFullscreenCourseList(response: BaseExplore.FullscreenCourseListModulePresentation.Response)
    func presentCourseInfo(response: BaseExplore.CourseInfoPresentation.Response)
    func presentCourseSyllabus(response: BaseExplore.CourseSyllabusPresentation.Response)
    func presentLastStep(response: BaseExplore.LastStepPresentation.Response)
    func presentAuthorization(response: BaseExplore.AuthorizationPresentation.Response)
    func presentPaidCourseBuying(response: BaseExplore.PaidCourseBuyingPresentation.Response)
    func presentProfile(response: BaseExplore.ProfilePresentation.Response)
}

class BaseExplorePresenter: BaseExplorePresenterProtocol {
    weak var viewController: BaseExploreViewControllerProtocol?

    private let urlFactory: StepikURLFactory

    init(urlFactory: StepikURLFactory) {
        self.urlFactory = urlFactory
    }

    func presentFullscreenCourseList(response: BaseExplore.FullscreenCourseListModulePresentation.Response) {
        self.viewController?.displayFullscreenCourseList(
            viewModel: .init(
                presentationDescription: response.presentationDescription,
                courseListType: response.courseListType
            )
        )
    }

    func presentCourseInfo(response: BaseExplore.CourseInfoPresentation.Response) {
        self.viewController?.displayCourseInfo(
            viewModel: .init(courseID: response.course.id, courseViewSource: response.courseViewSource)
        )
    }

    func presentCourseSyllabus(response: BaseExplore.CourseSyllabusPresentation.Response) {
        self.viewController?.displayCourseSyllabus(
            viewModel: .init(courseID: response.course.id, courseViewSource: response.courseViewSource)
        )
    }

    func presentLastStep(response: BaseExplore.LastStepPresentation.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive,
                courseContinueSource: response.courseContinueSource,
                courseViewSource: response.courseViewSource
            )
        )
    }

    func presentAuthorization(response: BaseExplore.AuthorizationPresentation.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }

    func presentPaidCourseBuying(response: BaseExplore.PaidCourseBuyingPresentation.Response) {
        if let payForCourseURL = self.urlFactory.makePayForCourse(id: response.course.id) {
            self.viewController?.displayPaidCourseBuying(viewModel: .init(urlPath: payForCourseURL.absoluteString))
        }
    }

    func presentProfile(response: BaseExplore.ProfilePresentation.Response) {
        self.viewController?.displayProfile(viewModel: .init(userID: response.userID))
    }
}
