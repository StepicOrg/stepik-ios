import CoreData
import SwiftDate
import SwiftyJSON

final class CourseBenefitByMonth: NSManagedObject, ManagedObject, JSONSerializable {
    typealias IdType = String

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }
    
    var date: DateInRegion? {
        self.dateString.toISODate(region: Date.europeMoscowRegion)
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].stringValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.dateString = json[JSONKey.date.rawValue].stringValue
        self.yearNumber = json[JSONKey.year.rawValue].intValue
        self.monthNumber = json[JSONKey.month.rawValue].intValue
        self.countPayments = json[JSONKey.countPayments.rawValue].intValue
        self.countCoursePayments = json[JSONKey.countCoursePayments.rawValue].intValue
        self.countInvoicePayments = json[JSONKey.countInvoicePayments.rawValue].intValue
        self.countZPayments = json[JSONKey.countZPayments.rawValue].intValue
        self.countNonZPayments = json[JSONKey.countNonZPayments.rawValue].intValue
        self.countRefunds = json[JSONKey.countRefunds.rawValue].intValue
        self.currencyCode = json[JSONKey.currencyCode.rawValue].stringValue
        self.totalTurnover = json[JSONKey.totalTurnover.rawValue].floatValue
        self.totalUserIncome = json[JSONKey.totalUserIncome.rawValue].floatValue
        self.totalRefunds = json[JSONKey.totalRefunds.rawValue].floatValue
    }

    enum JSONKey: String {
        case id
        case user
        case date
        case year
        case month
        case countPayments = "count_payments"
        case countCoursePayments = "count_course_payments"
        case countInvoicePayments = "count_invoice_payments"
        case countZPayments = "count_z_payments"
        case countNonZPayments = "count_non_z_payments"
        case countRefunds = "count_refunds"
        case currencyCode = "currency_code"
        case totalTurnover = "total_turnover"
        case totalUserIncome = "total_user_income"
        case totalRefunds = "total_refunds"
    }
}
