import Foundation

struct CourseRevenueTabPurchasesViewModel {
    let uniqueIdentifier: UniqueIdentifierType

    let formattedDate: String
    let buyerName: String
    let promoCodeName: String?
    let formattedPaymentAmount: String
    let formattedAmount: String
    let formattedSeatsCount: String?

    let isDebited: Bool
    let isRefunded: Bool
    let isZLinkUsed: Bool
    let isInvoicePayment: Bool
}
