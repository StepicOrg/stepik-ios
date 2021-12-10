import Foundation

struct CourseInfoPurchaseModalViewModel {
    let courseTitle: String
    let courseCoverImageURL: URL?

    let disclaimer: String

    let price: CourseInfoPurchaseModalPriceViewModel
    let wishlist: CourseInfoPurchaseModalWishlistViewModel
}

struct CourseInfoPurchaseModalPriceViewModel {
    let displayPrice: String
    let promoDisplayPrice: String?
    let promoCodeName: String?
}

struct CourseInfoPurchaseModalWishlistViewModel {
    let title: String
    let isInWishlist: Bool
    let isLoading: Bool
}
