import Foundation
import PromiseKit

protocol WriteCourseReviewInteractorProtocol {
    func doSomeAction(request: WriteCourseReview.SomeAction.Request)
}

final class WriteCourseReviewInteractor: WriteCourseReviewInteractorProtocol {
    weak var moduleOutput: WriteCourseReviewOutputProtocol?

    private let presenter: WriteCourseReviewPresenterProtocol
    private let provider: WriteCourseReviewProviderProtocol

    init(
        presenter: WriteCourseReviewPresenterProtocol,
        provider: WriteCourseReviewProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: WriteCourseReview.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}
