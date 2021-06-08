import Foundation

struct CourseBenefitPlainObject {
    let id: Int
    let userID: Int
    let courseID: Int
    let time: Date?
    let statusString: String
    let amount: Float
    let currencyCode: String
    let totalIncome: Float
    let paymentAmount: Float
    let buyerID: Int
    let isZLinkUsed: Bool
    let promoCode: String?

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
        self.totalIncome = courseBenefit.totalIncome
        self.paymentAmount = courseBenefit.paymentAmount
        self.buyerID = courseBenefit.buyerID
        self.isZLinkUsed = courseBenefit.isZLinkUsed
        self.promoCode = courseBenefit.promoCode
    }
}
