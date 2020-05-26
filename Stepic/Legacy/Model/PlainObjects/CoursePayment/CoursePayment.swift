import Foundation
import SwiftyJSON

final class CoursePayment: JSONSerializable {
    typealias IdType = Int
    typealias Data = [String: Any]

    var id: IdType = -1
    var userID: User.IdType = -1
    var courseID: Course.IdType = -1
    var amount: Float = 0
    var currencyCode: String = ""
    var statusStringValue: String = ""
    var isPaid: Bool = false
    var data: Data?
    var paymentProviderStringValue: String = PaymentProvider.apple.rawValue

    var status: Status? {
        Status(rawValue: self.statusStringValue)
    }

    var paymentProvider: PaymentProvider? {
        PaymentProvider(rawValue: self.paymentProviderStringValue)
    }

    var json: JSON {
        let paymentProvider: PaymentProvider = self.paymentProvider ?? .apple

        var dict: JSON = [
            JSONKey.course.rawValue: self.courseID,
            JSONKey.paymentProvider.rawValue: paymentProvider.rawValue
        ]

        if let data = self.data {
            dict[JSONKey.data.rawValue] = JSON(data)
        }

        return dict
    }

    init(courseID: Course.IdType, data: Data, paymentProvider: PaymentProvider = .apple) {
        self.courseID = courseID
        self.data = data
        self.paymentProviderStringValue = paymentProvider.rawValue
    }

    init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.amount = json[JSONKey.amount.rawValue].floatValue
        self.currencyCode = json[JSONKey.currencyCode.rawValue].stringValue
        self.statusStringValue = json[JSONKey.status.rawValue].stringValue
        self.isPaid = json[JSONKey.isPaid.rawValue].boolValue
        self.data = json[JSONKey.data.rawValue].dictionaryObject
        self.paymentProviderStringValue = json[JSONKey.paymentProvider.rawValue].stringValue
    }

    enum Status: String {
        case pending
        case amountBlocked = "amount_blocked"
        case success
        case canceled
        case failed
        case expired
    }

    enum PaymentProvider: String {
        case apple = "Apple"
    }

    enum DataFactory {
        static func generateDataForAppleProvider(
            receiptData: String,
            bundleID: String,
            amount: Double,
            currency: String
        ) -> Data {
            [
                "receipt_data": receiptData,
                "bundle_id": bundleID,
                "amount": amount,
                "currency": currency
            ]
        }
    }

    enum JSONKey: String {
        case id = "id"
        case user = "user"
        case course = "course"
        case amount = "amount"
        case currencyCode = "currency_code"
        case status = "status"
        case isPaid = "is_paid"
        case data = "data"
        case paymentProvider = "payment_provider"
    }
}

extension CoursePayment: CustomStringConvertible {
    var description: String {
        """
        CoursePayment(id: \(self.id), \
        userID: \(self.userID), \
        courseID: \(self.courseID), \
        amount: \(self.amount), \
        currencyCode: \(self.currencyCode), \
        statusStringValue: \(self.statusStringValue), \
        isPaid: \(self.isPaid), \
        data: \(String(describing: self.data)), \
        paymentProviderStringValue: \(self.paymentProviderStringValue))
        """
    }
}
