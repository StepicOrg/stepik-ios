import Foundation

struct CourseInfoProgressViewModel {
    let progress: Float
    let progressLabelText: String
}

struct CourseInfoHeaderViewModel {
    let title: String
    let coverImageURL: URL?

    let rating: Int
    let learnersLabelText: String
    let progress: CourseInfoProgressViewModel?
    let isVerified: Bool
    let isEnrolled: Bool
    let isFavorite: Bool
    let isArchived: Bool
    let isWishlisted: Bool
    let isWishlistAvailable: Bool
    let isTryForFreeAvailable: Bool
    let isRevenueAvailable: Bool
    let unsupportedIAPPurchaseText: String?
    let buttonDescription: ButtonDescription

    struct ButtonDescription {
        let title: String
        let subtitle: String?
        let isCallToAction: Bool
        let isEnabled: Bool
        let isPromo: Bool
        let isWishlist: Bool
    }
}
