import Foundation
import PromiseKit

protocol UserCoursesReviewsInteractorProtocol {
    func doReviewsLoad(request: UserCoursesReviews.ReviewsLoad.Request)
}

final class UserCoursesReviewsInteractor: UserCoursesReviewsInteractorProtocol {
    weak var moduleOutput: UserCoursesReviewsOutputProtocol?

    private let presenter: UserCoursesReviewsPresenterProtocol
    private let provider: UserCoursesReviewsProviderProtocol

    init(
        presenter: UserCoursesReviewsPresenterProtocol,
        provider: UserCoursesReviewsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doReviewsLoad(request: UserCoursesReviews.ReviewsLoad.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension UserCoursesReviewsInteractor: UserCoursesReviewsInputProtocol {}
