import CoreData
import SwiftyJSON

final class CourseBenefit: NSManagedObject, ManagedObject, JSONSerializable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    var status: CourseBenefitStatus? { CourseBenefitStatus(rawValue: self.statusString) }

    var userSharePercent: Float? {
        self.course?.courseBeneficiaries.first(where: { $0.userID == self.userID })?.percent
    }

    var isManualBenefit: Bool { self.buyerID == nil && !self.isInvoicePayment }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
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
        self.paymentAmount = json[JSONKey.paymentAmount.rawValue].floatValue
        self.buyerID = json[JSONKey.buyer.rawValue].int
        // APPS-3653: Renamed
        self.isAuthorLinkUsed = json[JSONKey.isZLinkUsed.rawValue].boolValue
        self.isInvoicePayment = json[JSONKey.isInvoicePayment.rawValue].boolValue
        self.promoCode = json[JSONKey.promoCode.rawValue].string
        self.seatsCount = json[JSONKey.seatsCount.rawValue].int
        self.descriptionString = json[JSONKey.description.rawValue].stringValue
    }

    enum JSONKey: String {
        case id
        case user
        case course
        case time
        case status
        case amount
        case currencyCode = "currency_code"
        case paymentAmount = "payment_amount"
        case buyer
        case isZLinkUsed = "is_z_link_used"
        case isInvoicePayment = "is_invoice_payment"
        case promoCode = "promo_code"
        case seatsCount = "seats_count"
        case description
    }
}
