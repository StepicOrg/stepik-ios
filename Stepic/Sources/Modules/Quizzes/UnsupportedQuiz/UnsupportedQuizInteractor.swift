import Foundation
import PromiseKit

protocol UnsupportedQuizInteractorProtocol {
    func doUnsupportedQuizAction(request: UnsupportedQuiz.UnsupportedQuizPresentation.Request)
}

final class UnsupportedQuizInteractor: UnsupportedQuizInteractorProtocol {
    private let presenter: UnsupportedQuizPresenterProtocol
    private let analytics: Analytics

    private let stepURLPath: String

    init(
        stepURLPath: String,
        presenter: UnsupportedQuizPresenterProtocol,
        analytics: Analytics
    ) {
        self.stepURLPath = stepURLPath
        self.presenter = presenter
        self.analytics = analytics
    }

    func doUnsupportedQuizAction(request: UnsupportedQuiz.UnsupportedQuizPresentation.Request) {
        self.analytics.send(.solveQuizInWebTapped)
        self.presenter.presentUnsupportedQuiz(response: .init(stepURLPath: self.stepURLPath))
    }
}
