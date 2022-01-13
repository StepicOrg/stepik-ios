import Foundation

struct CourseRevenueTabMonthlyViewModel {
    let uniqueIdentifier: UniqueIdentifierType

    let formattedDate: String
    let formattedTotalIncome: String
    let formattedTotalTurnover: String
    let formattedTotalRefunds: String

    let totalIncome: Float
    let totalRefunds: Float

    let countPayments: Int
    let countNonZPayments: Int
    let countInvoicePayments: Int
    let countZPayments: Int
}
