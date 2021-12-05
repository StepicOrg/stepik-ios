import Foundation

struct CourseInfoPurchaseModalViewModel {
    let courseTitle: String
    let courseCoverImageURL: URL?

    let price: CourseInfoPurchaseModalPriceViewModel

    let isInWishList: Bool
}

struct CourseInfoPurchaseModalPriceViewModel {
    let displayPrice: String
    let promoDisplayPrice: String?
    let promoCodeName: String?
}
