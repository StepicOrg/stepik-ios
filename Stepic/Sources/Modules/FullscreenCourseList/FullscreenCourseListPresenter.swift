import UIKit

protocol FullscreenCourseListPresenterProtocol {
    func presentCourseInfo(response: FullscreenCourseList.CourseInfoPresentation.Response)
    func presentCourseSyllabus(response: FullscreenCourseList.CourseSyllabusPresentation.Response)
    func presentLastStep(response: FullscreenCourseList.LastStepPresentation.Response)
    func presentAuthorization(response: FullscreenCourseList.PresentAuthorization.Response)
    func presentPlaceholder(response: FullscreenCourseList.PresentPlaceholder.Response)
    func presentHidePlaceholder(response: FullscreenCourseList.HidePlaceholder.Response)
    func presentPaidCourseBuying(response: FullscreenCourseList.PaidCourseBuyingPresentation.Response)
    func presentSimilarAuthors(response: FullscreenCourseList.SimilarAuthorsPresentation.Response)
    func presentSimilarCourseLists(response: FullscreenCourseList.SimilarCourseListsPresentation.Response)
    func presentProfile(response: FullscreenCourseList.ProfilePresentation.Response)
    func presentFullscreenCourseList(response: FullscreenCourseList.FullscreenCourseListModulePresentation.Response)
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
                courseContinueSource: response.courseContinueSource,
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

    func presentHidePlaceholder(response: FullscreenCourseList.HidePlaceholder.Response) {
        self.viewController?.displayHidePlaceholder(viewModel: .init())
    }

    func presentPaidCourseBuying(response: FullscreenCourseList.PaidCourseBuyingPresentation.Response) {
        if let payForCourseURL = self.urlFactory.makePayForCourse(id: response.course.id) {
            self.viewController?.displayPaidCourseBuying(viewModel: .init(urlPath: payForCourseURL.absoluteString))
        }
    }

    func presentSimilarAuthors(response: FullscreenCourseList.SimilarAuthorsPresentation.Response) {
        self.viewController?.displaySimilarAuthors(viewModel: .init(ids: response.ids))
    }

    func presentSimilarCourseLists(response: FullscreenCourseList.SimilarCourseListsPresentation.Response) {
        self.viewController?.displaySimilarCourseLists(viewModel: .init(ids: response.ids))
    }

    func presentProfile(response: FullscreenCourseList.ProfilePresentation.Response) {
        self.viewController?.displayProfile(viewModel: .init(userID: response.userID))
    }

    func presentFullscreenCourseList(response: FullscreenCourseList.FullscreenCourseListModulePresentation.Response) {
        self.viewController?.displayFullscreenCourseList(
            viewModel: .init(
                courseListType: response.courseListType,
                presentationDescription: response.presentationDescription
            )
        )
    }
}
