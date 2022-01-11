import Foundation

struct CourseBenefitDetailViewModel {
    let title: String
    let formattedDate: String
    let courseTitle: String
    let buyerName: String?
    let formattedSeatsCount: String?
    let formattedPaymentAmount: String
    let promoCodeName: String?
    let channelName: String
    let formattedAmountPercent: String
    let formattedAmount: String

    let isRefunded: Bool
    let isInvoicePayment: Bool
    let isManualBenefit: Bool
}
