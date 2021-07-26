import Foundation
import PromiseKit

protocol StepQuizReviewInteractorProtocol {
    func doSomeAction(request: StepQuizReview.SomeAction.Request)
}

final class StepQuizReviewInteractor: StepQuizReviewInteractorProtocol {
    weak var moduleOutput: StepQuizReviewOutputProtocol?

    private let presenter: StepQuizReviewPresenterProtocol
    private let provider: StepQuizReviewProviderProtocol

    init(
        presenter: StepQuizReviewPresenterProtocol,
        provider: StepQuizReviewProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: StepQuizReview.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension StepQuizReviewInteractor: StepQuizReviewInputProtocol {}
