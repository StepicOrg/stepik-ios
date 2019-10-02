import UIKit

final class WriteCourseReviewAssembly: Assembly {
    private let courseID: Course.IdType
    private var courseReview: CourseReview?

    private weak var moduleOutput: WriteCourseReviewOutputProtocol?

    init(
        courseID: Course.IdType,
        courseReview: CourseReview? = nil,
        output: WriteCourseReviewOutputProtocol? = nil
    ) {
        self.courseID = courseID
        self.courseReview = courseReview
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = WriteCourseReviewProvider(
            courseReviewsNetworkService: CourseReviewsNetworkService(
                courseReviewsAPI: CourseReviewsAPI()
            ),
            userAccountService: UserAccountService()
        )
        let presenter = WriteCourseReviewPresenter()
        let interactor = WriteCourseReviewInteractor(
            courseID: self.courseID,
            courseReview: self.courseReview,
            presenter: presenter,
            provider: provider
        )
        let viewController = WriteCourseReviewViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
