import UIKit

final class NewStringQuizAssembly: Assembly {
    var moduleInput: NewStringQuizInputProtocol?

    private weak var moduleOutput: NewStringQuizOutputProtocol?
    private let type: NewStringQuiz.DataType

    init(type: NewStringQuiz.DataType, output: NewStringQuizOutputProtocol? = nil) {
        self.moduleOutput = output
        self.type = type
    }

    func makeModule() -> UIViewController {
        let provider = NewStringQuizProvider()
        let presenter = NewStringQuizPresenter(type: self.type)
        let interactor = NewStringQuizInteractor(type: self.type, presenter: presenter, provider: provider)
        let viewController = NewStringQuizViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
