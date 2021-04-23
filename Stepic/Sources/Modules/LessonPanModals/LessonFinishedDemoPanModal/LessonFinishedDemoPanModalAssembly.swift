import UIKit

final class LessonFinishedDemoPanModalAssembly: Assembly {
    private weak var moduleOutput: LessonFinishedDemoPanModalOutputProtocol?

    init(output: LessonFinishedDemoPanModalOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = LessonFinishedDemoPanModalProvider()
        let presenter = LessonFinishedDemoPanModalPresenter()
        let interactor = LessonFinishedDemoPanModalInteractor(presenter: presenter, provider: provider)
        let viewController = LessonFinishedDemoPanModalViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
