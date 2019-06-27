import Foundation
import PromiseKit

protocol NewChoiceQuizInteractorProtocol { }

final class NewChoiceQuizInteractor: NewChoiceQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewChoiceQuizPresenterProtocol
    private let provider: NewChoiceQuizProviderProtocol

    init(
        presenter: NewChoiceQuizPresenterProtocol,
        provider: NewChoiceQuizProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    enum Error: Swift.Error {
        case something
    }
}

extension NewChoiceQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {

    }

    func update(status: QuizStatus?) {
        
    }
}
