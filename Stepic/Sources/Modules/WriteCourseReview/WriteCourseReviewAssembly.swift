import UIKit

final class WriteCourseReviewAssembly: Assembly {
    private weak var moduleOutput: WriteCourseReviewOutputProtocol?

    init(output: WriteCourseReviewOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = WriteCourseReviewProvider()
        let presenter = WriteCourseReviewPresenter()
        let interactor = WriteCourseReviewInteractor(presenter: presenter, provider: provider)
        let viewController = WriteCourseReviewViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
