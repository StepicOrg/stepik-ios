import Foundation

enum DiscountingPolicy: String {
    case noDiscount = "no_discount"
    case inverse
    case firstOne = "first_one"
    case firstThree = "first_three"

    var numberOfTries: Int {
        switch self {
        case .noDiscount, .inverse:
            return Int.max
        case .firstOne:
            return 1
        case .firstThree:
            return 3
        }
    }
}
