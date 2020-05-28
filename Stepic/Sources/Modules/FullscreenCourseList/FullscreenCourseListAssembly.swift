import UIKit

final class FullscreenCourseListAssembly: Assembly {
    let presentationDescription: CourseList.PresentationDescription?
    let courseListType: CourseListType
    private let courseViewSource: AnalyticsEvent.CourseViewSource

    init(
        presentationDescription: CourseList.PresentationDescription? = nil,
        courseListType: CourseListType,
        courseViewSource: AnalyticsEvent.CourseViewSource? = nil
    ) {
        self.presentationDescription = presentationDescription
        self.courseListType = courseListType
        self.courseViewSource = courseViewSource ?? .query(courseListType: courseListType)
    }

    func makeModule() -> UIViewController {
        let presenter = FullscreenCourseListPresenter()
        let interactor = FullscreenCourseListInteractor(
            presenter: presenter,
            networkReachabilityService: NetworkReachabilityService()
        )
        let viewController = FullscreenCourseListViewController(
            interactor: interactor,
            courseListType: self.courseListType,
            presentationDescription: self.presentationDescription,
            courseViewSource: self.courseViewSource
        )

        presenter.viewController = viewController
        return viewController
    }
}
