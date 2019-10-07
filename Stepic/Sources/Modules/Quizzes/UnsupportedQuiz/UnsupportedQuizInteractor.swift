import Foundation
import PromiseKit

protocol UnsupportedQuizInteractorProtocol {
    func doUnsupportedQuizPresentation(request: UnsupportedQuiz.UnsupportedQuizPresentation.Request)
}

final class UnsupportedQuizInteractor: UnsupportedQuizInteractorProtocol {
    private let presenter: UnsupportedQuizPresenterProtocol

    private let stepURLPath: String

    init(
        stepURLPath: String,
        presenter: UnsupportedQuizPresenterProtocol
    ) {
        self.stepURLPath = stepURLPath
        self.presenter = presenter
    }

    func doUnsupportedQuizPresentation(request: UnsupportedQuiz.UnsupportedQuizPresentation.Request) {
        // FIXME: analytics dependency
        AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.solveInWebPressed)

        self.presenter.presentUnsupportedQuiz(
            response: UnsupportedQuiz.UnsupportedQuizPresentation.Response(stepURLPath: self.stepURLPath)
        )
    }
}
