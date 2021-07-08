import CoreData
import Foundation
import SwiftDate
import SwiftyJSON

final class CourseBenefitByMonth: NSManagedObject, JSONSerializable {
    typealias IdType = String

    var date: DateInRegion? {
        self.dateString.toISODate()
    }

    required convenience init(json: JSON) {
        self.init()
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].stringValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.dateString = json[JSONKey.date.rawValue].stringValue
        self.yearNumber = json[JSONKey.year.rawValue].intValue
        self.monthNumber = json[JSONKey.month.rawValue].intValue
        self.countPayments = json[JSONKey.countPayments.rawValue].intValue
        self.countZPayments = json[JSONKey.countZPayments.rawValue].intValue
        self.countNonZPayments = json[JSONKey.countNonZPayments.rawValue].intValue
        self.countRefunds = json[JSONKey.countRefunds.rawValue].intValue
        self.currencyCode = json[JSONKey.currencyCode.rawValue].stringValue
        self.totalTurnover = json[JSONKey.totalTurnover.rawValue].floatValue
        self.totalUserIncome = json[JSONKey.totalUserIncome.rawValue].floatValue
    }

    enum JSONKey: String {
        case id
        case user
        case date
        case year
        case month
        case countPayments = "count_payments"
        case countZPayments = "count_z_payments"
        case countNonZPayments = "count_non_z_payments"
        case countRefunds = "count_refunds"
        case currencyCode = "currency_code"
        case totalTurnover = "total_turnover"
        case totalUserIncome = "total_user_income"
    }
}
