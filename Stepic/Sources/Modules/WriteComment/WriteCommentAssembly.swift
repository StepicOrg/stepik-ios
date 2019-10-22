import UIKit

final class WriteCommentAssembly: Assembly {
    var moduleInput: WriteCommentInputProtocol?

    private weak var moduleOutput: WriteCommentOutputProtocol?

    init(output: WriteCommentOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = WriteCommentProvider()
        let presenter = WriteCommentPresenter()
        let interactor = WriteCommentInteractor(presenter: presenter, provider: provider)
        let viewController = WriteCommentViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}