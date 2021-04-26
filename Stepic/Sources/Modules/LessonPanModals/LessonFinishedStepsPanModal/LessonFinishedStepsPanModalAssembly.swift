import UIKit

final class LessonFinishedStepsPanModalAssembly: Assembly {
    var moduleInput: LessonFinishedStepsPanModalInputProtocol?

    private weak var moduleOutput: LessonFinishedStepsPanModalOutputProtocol?

    init(output: LessonFinishedStepsPanModalOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = LessonFinishedStepsPanModalProvider()
        let presenter = LessonFinishedStepsPanModalPresenter()
        let interactor = LessonFinishedStepsPanModalInteractor(presenter: presenter, provider: provider)
        let viewController = LessonFinishedStepsPanModalViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
