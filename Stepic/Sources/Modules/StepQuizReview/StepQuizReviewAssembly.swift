import UIKit

final class StepQuizReviewAssembly: Assembly {
    var moduleInput: StepQuizReviewInputProtocol?

    private weak var moduleOutput: StepQuizReviewOutputProtocol?

    init(output: StepQuizReviewOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = StepQuizReviewProvider()
        let presenter = StepQuizReviewPresenter()
        let interactor = StepQuizReviewInteractor(presenter: presenter, provider: provider)
        let viewController = StepQuizReviewViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
