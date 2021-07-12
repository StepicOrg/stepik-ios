import Foundation

struct CourseRevenueTabMonthlyViewModel {
    let uniqueIdentifier: UniqueIdentifierType

    let formattedDate: String
    let formattedTotalIncome: String
    let formattedTotalTurnover: String
    let formattedTotalRefunds: String

    let totalIncome: Float
    let countPayments: Int
    let countNonZPayments: Int
    let countZPayments: Int
}
