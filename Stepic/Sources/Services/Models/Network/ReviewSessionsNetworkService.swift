import Foundation
import PromiseKit

protocol ReviewSessionsNetworkServiceProtocol: AnyObject {
}

final class ReviewSessionsNetworkService: ReviewSessionsNetworkServiceProtocol {
    private let reviewSessionsAPI: ReviewSessionsAPI

    init(reviewSessionsAPI: ReviewSessionsAPI) {
        self.reviewSessionsAPI = reviewSessionsAPI
    }
}
