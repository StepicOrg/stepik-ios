import UIKit

final class NewStringQuizAssembly: QuizAssembly {
    var moduleInput: QuizInputProtocol?
    weak var moduleOutput: QuizOutputProtocol?

    private let type: NewStringQuiz.DataType

    init(type: NewStringQuiz.DataType) {
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
