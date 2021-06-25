import Foundation

struct PromoCode {
    let courseID: Int
    let name: String
    let price: Float
    let currencyCode: String
    var expireDate: Date?

    var isValid: Bool {
        if let expireDate = self.expireDate {
            return expireDate > Date()
        } else {
            return true
        }
    }
}
