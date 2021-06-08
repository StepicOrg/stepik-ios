import Foundation

struct CourseBenefitSummaryPlainObject {
    let id: Int
    let beginPaymentDate: Date?
    let currentDate: Date?
    let totalIncome: Float
    let totalTurnover: Float
    let totalUserIncome: Float
    let monthIncome: Float
    let monthTurnover: Float
    let monthUserIncome: Float
    let currencyCode: String
}

extension CourseBenefitSummaryPlainObject {
    init(courseBenefitSummary: CourseBenefitSummary) {
        self.id = courseBenefitSummary.id
        self.beginPaymentDate = courseBenefitSummary.beginPaymentDate
        self.currentDate = courseBenefitSummary.currentDate
        self.totalIncome = courseBenefitSummary.totalIncome
        self.totalTurnover = courseBenefitSummary.totalTurnover
        self.totalUserIncome = courseBenefitSummary.totalUserIncome
        self.monthIncome = courseBenefitSummary.monthIncome
        self.monthTurnover = courseBenefitSummary.monthTurnover
        self.monthUserIncome = courseBenefitSummary.monthUserIncome
        self.currencyCode = courseBenefitSummary.currencyCode
    }
}
