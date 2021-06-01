import UIKit

final class WriteCourseReviewAssembly: Assembly {
    private let courseID: Course.IdType
    private let presentationContext: WriteCourseReview.PresentationContext
    private let navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState

    private weak var moduleOutput: WriteCourseReviewOutputProtocol?

    init(
        courseID: Course.IdType,
        presentationContext: WriteCourseReview.PresentationContext,
        navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init(),
        output: WriteCourseReviewOutputProtocol? = nil
    ) {
        self.courseID = courseID
        self.presentationContext = presentationContext
        self.navigationBarAppearance = navigationBarAppearance
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = WriteCourseReviewProvider(
            coursesPersistenceService: CoursesPersistenceService(),
            courseReviewsNetworkService: CourseReviewsNetworkService(
                courseReviewsAPI: CourseReviewsAPI()
            ),
            userAccountService: UserAccountService()
        )
        let presenter = WriteCourseReviewPresenter()
        let interactor = WriteCourseReviewInteractor(
            courseID: self.courseID,
            presentationContext: self.presentationContext,
            presenter: presenter,
            provider: provider
        )
        let viewController = WriteCourseReviewViewController(
            interactor: interactor,
            appearance: .init(
                navigationBarAppearance: self.navigationBarAppearance
            )
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
