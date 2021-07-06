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
    let rating: Int
    let averageRating: Float
    let reviewsCount: Int
    let reviewsDistribution: [Int]
    let formattedRating: String
    let formattedReviewsCount: String
    let formattedReviewsDistribution: [String]

    static var empty: CourseInfoTabReviewsSummaryViewModel {
        .init(
            rating: 0,
            averageRating: 0,
            reviewsCount: 0,
            reviewsDistribution: [],
            formattedRating: "",
            formattedReviewsCount: "",
            formattedReviewsDistribution: []
        )
    }
}
