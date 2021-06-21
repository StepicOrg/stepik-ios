import UIKit

final class CourseRevenueAssembly: Assembly {
    private let courseID: Course.IdType

    init(courseID: Course.IdType) {
        self.courseID = courseID
    }

    func makeModule() -> UIViewController {
        let provider = CourseRevenueProvider(courseID: self.courseID)
        let presenter = CourseRevenuePresenter()
        let interactor = CourseRevenueInteractor(
            courseID: self.courseID,
            presenter: presenter,
            provider: provider
        )
        let viewController = CourseRevenueViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
