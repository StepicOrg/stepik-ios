import CoreData
import SwiftyJSON

final class CourseBenefitSummary: NSManagedObject, ManagedObject, JSONSerializable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    var isEmpty: Bool {
        self.totalUserIncome.isZero
            && self.totalTurnover.isZero
            && self.monthUserIncome.isZero
            && self.monthTurnover.isZero
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.beginPaymentDate = json[JSONKey.beginPaymentDate.rawValue].string?.toISODate()?.date
        self.currentDate = Parser.dateFromTimedateJSON(json[JSONKey.currentDate.rawValue])
        self.totalIncome = json[JSONKey.totalIncome.rawValue].floatValue
        self.totalTurnover = json[JSONKey.totalTurnover.rawValue].floatValue
        self.totalUserIncome = json[JSONKey.totalUserIncome.rawValue].floatValue
        self.monthIncome = json[JSONKey.monthIncome.rawValue].floatValue
        self.monthTurnover = json[JSONKey.monthTurnover.rawValue].floatValue
        self.monthUserIncome = json[JSONKey.monthUserIncome.rawValue].floatValue
        self.currencyCode = json[JSONKey.currencyCode.rawValue].stringValue
    }

    enum JSONKey: String {
        case id
        case beginPaymentDate = "begin_payment_date"
        case currentDate = "current_date"
        case totalIncome = "total_income"
        case totalTurnover = "total_turnover"
        case totalUserIncome = "total_user_income"
        case monthIncome = "month_income"
        case monthTurnover = "month_turnover"
        case monthUserIncome = "month_user_income"
        case currencyCode = "currency_code"
    }
}
