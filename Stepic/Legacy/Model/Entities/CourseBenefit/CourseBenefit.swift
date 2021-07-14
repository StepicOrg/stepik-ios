import CoreData
import Foundation
import SwiftyJSON

final class CourseBenefit: NSManagedObject, JSONSerializable {
    typealias IdType = Int

    var status: CourseBenefitStatus? { CourseBenefitStatus(rawValue: self.statusString) }

    var userSharePercent: Float? {
        self.course?.courseBeneficiaries.first(where: { $0.userID == self.userID })?.percent
    }

    required convenience init(json: JSON) {
        self.init()
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.time = Parser.dateFromTimedateJSON(json[JSONKey.time.rawValue])
            ?? json[JSONKey.time.rawValue].string?.toISODate()?.date
        self.statusString = json[JSONKey.status.rawValue].stringValue
        self.amount = json[JSONKey.amount.rawValue].floatValue
        self.currencyCode = json[JSONKey.currencyCode.rawValue].stringValue
        self.totalIncome = json[JSONKey.totalIncome.rawValue].floatValue
        self.paymentAmount = json[JSONKey.paymentAmount.rawValue].floatValue
        self.buyerID = json[JSONKey.buyer.rawValue].intValue
        self.isZLinkUsed = json[JSONKey.isZLinkUsed.rawValue].boolValue
        self.promoCode = json[JSONKey.promoCode.rawValue].string
    }

    enum JSONKey: String {
        case id
        case user
        case course
        case time
        case status
        case amount
        case currencyCode = "currency_code"
        case totalIncome = "total_income"
        case paymentAmount = "payment_amount"
        case buyer
        case isZLinkUsed = "is_z_link_used"
        case promoCode = "promo_code"
    }
}
