import Foundation

struct CourseBenefitPlainObject {
    let id: Int
    let userID: Int
    let courseID: Int
    let time: Date?
    let statusString: String
    let amount: Float
    let currencyCode: String
    let paymentAmount: Float
    let buyerID: Int?
    let isAuthorLinkUsed: Bool
    let isInvoicePayment: Bool
    let isManualBenefit: Bool
    let promoCode: String?
    let seatsCount: Int?
    let descriptionString: String

    var status: CourseBenefitStatus? { CourseBenefitStatus(rawValue: self.statusString) }
}

extension CourseBenefitPlainObject {
    init(courseBenefit: CourseBenefit) {
        self.id = courseBenefit.id
        self.userID = courseBenefit.userID
        self.courseID = courseBenefit.courseID
        self.time = courseBenefit.time
        self.statusString = courseBenefit.statusString
        self.amount = courseBenefit.amount
        self.currencyCode = courseBenefit.currencyCode
        self.paymentAmount = courseBenefit.paymentAmount
        self.buyerID = courseBenefit.buyerID
        self.isAuthorLinkUsed = courseBenefit.isAuthorLinkUsed
        self.isInvoicePayment = courseBenefit.isInvoicePayment
        self.isManualBenefit = courseBenefit.isManualBenefit
        self.promoCode = courseBenefit.promoCode
        self.seatsCount = courseBenefit.seatsCount
        self.descriptionString = courseBenefit.descriptionString
    }
}
