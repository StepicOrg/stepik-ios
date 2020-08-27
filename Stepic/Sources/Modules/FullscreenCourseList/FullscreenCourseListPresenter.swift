import UIKit

protocol FullscreenCourseListPresenterProtocol {
    func presentCourseInfo(response: FullscreenCourseList.CourseInfoPresentation.Response)
    func presentCourseSyllabus(response: FullscreenCourseList.CourseSyllabusPresentation.Response)
    func presentLastStep(response: FullscreenCourseList.LastStepPresentation.Response)
    func presentAuthorization(response: FullscreenCourseList.PresentAuthorization.Response)
    func presentPlaceholder(response: FullscreenCourseList.PresentPlaceholder.Response)
    func presentPaidCourseBuying(response: FullscreenCourseList.PaidCourseBuyingPresentation.Response)
}

final class FullscreenCourseListPresenter: FullscreenCourseListPresenterProtocol {
    weak var viewController: FullscreenCourseListViewControllerProtocol?

    private let urlFactory: StepikURLFactory

    init(urlFactory: StepikURLFactory) {
        self.urlFactory = urlFactory
    }

    func presentCourseInfo(response: FullscreenCourseList.CourseInfoPresentation.Response) {
        self.viewController?.displayCourseInfo(
            viewModel: .init(courseID: response.course.id, courseViewSource: response.courseViewSource)
        )
    }

    func presentCourseSyllabus(response: FullscreenCourseList.CourseSyllabusPresentation.Response) {
        self.viewController?.displayCourseSyllabus(
            viewModel: .init(courseID: response.course.id, courseViewSource: response.courseViewSource)
        )
    }

    func presentLastStep(response: FullscreenCourseList.LastStepPresentation.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive,
                courseViewSource: response.courseViewSource
            )
        )
    }

    func presentAuthorization(response: FullscreenCourseList.PresentAuthorization.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }

    func presentPlaceholder(response: FullscreenCourseList.PresentPlaceholder.Response) {
        self.viewController?.displayPlaceholder(viewModel: .init(state: response.state))
    }

    func presentPaidCourseBuying(response: FullscreenCourseList.PaidCourseBuyingPresentation.Response) {
        if let payForCourseURL = self.urlFactory.makePayForCourse(id: response.course.id) {
            self.viewController?.displayPaidCourseBuying(viewModel: .init(urlPath: payForCourseURL.absoluteString))
        }
    }
}
