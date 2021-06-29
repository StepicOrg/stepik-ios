import Foundation

struct CourseInfoTabReviewsViewModel {
    // swiftlint:disable:next type_name
    typealias ID = Int

    let uniqueIdentifier: ID
    let userName: String
    let dateRepresentation: String
    let text: String
    let avatarImageURL: URL?
    let score: Int
    let isCurrentUserReview: Bool
}

struct CourseInfoTabReviewsSummaryViewModel {
    let rating: Float
    let reviewsCount: Int
    let reviewsDistribution: [Int]
    let formattedReviewsCount: String
    let formattedReviewsDistribution: [String]

    static var empty: CourseInfoTabReviewsSummaryViewModel {
        .init(
            rating: 0,
            reviewsCount: 0,
            reviewsDistribution: [],
            formattedReviewsCount: "",
            formattedReviewsDistribution: []
        )
    }
}
