import Foundation
import SwiftyJSON

final class SpecializationsCatalogBlockContentItem: CatalogBlockContentItem {
    override class var supportsSecureCoding: Bool { true }

    var id: Int
    var title: String
    var descriptionString: String
    var detailsURLString: String
    var priceString: String
    var discountString: String
    var currencyString: String
    var startDate: Date?
    var endDate: Date?
    var durationString: String

    override var hash: Int {
        var result = self.id.hashValue
        result = result &* 31 &+ self.title.hashValue
        result = result &* 31 &+ self.descriptionString.hashValue
        result = result &* 31 &+ self.detailsURLString.hashValue
        result = result &* 31 &+ self.priceString.hashValue
        result = result &* 31 &+ self.discountString.hashValue
        result = result &* 31 &+ self.currencyString.hashValue
        result = result &* 31 &+ (self.startDate?.hashValue ?? 0)
        result = result &* 31 &+ (self.endDate?.hashValue ?? 0)
        result = result &* 31 &+ self.durationString.hashValue
        return result
    }

    override var description: String {
        """
        SpecializationsCatalogBlockContentItem(id: \(self.id), \
        title: \(self.title), \
        description: \(self.descriptionString), \
        detailsURL: \(self.detailsURLString), \
        price: \(self.priceString), \
        discount: \(self.discountString), \
        currency: \(self.currencyString), \
        startDate: \(String(describing: self.startDate)), \
        endDate: \(String(describing: self.endDate)), \
        duration: \(self.durationString))
        """
    }

    /* Example data:
     {
        "id": 6,
        "title": "Big Data for Data Science",
        "description": "",
        "details_url": "http://academy.stepik.org/big-data",
        "price": "35000.00",
        "discount": "6000.00",
        "currency": "RUB",
        "start_date": "2021-02-12T03:00:01Z",
        "end_date": null,
        "duration": "6 недель"
     }
     */
    required init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.title = json[JSONKey.title.rawValue].stringValue
        self.descriptionString = json[JSONKey.description.rawValue].stringValue
        self.detailsURLString = json[JSONKey.detailsURL.rawValue].stringValue
        self.priceString = json[JSONKey.price.rawValue].stringValue
        self.discountString = json[JSONKey.discount.rawValue].stringValue
        self.currencyString = json[JSONKey.currency.rawValue].stringValue

        self.startDate = Parser.dateFromTimedateJSON(json[JSONKey.startDate.rawValue])
        self.endDate = Parser.dateFromTimedateJSON(json[JSONKey.endDate.rawValue])

        self.durationString = json[JSONKey.duration.rawValue].stringValue

        super.init(json: json)
    }

    required init?(coder: NSCoder) {
        guard let title = coder.decodeObject(forKey: JSONKey.title.rawValue) as? String,
              let description = coder.decodeObject(forKey: JSONKey.description.rawValue) as? String,
              let detailsURL = coder.decodeObject(forKey: JSONKey.detailsURL.rawValue) as? String,
              let price = coder.decodeObject(forKey: JSONKey.price.rawValue) as? String,
              let discount = coder.decodeObject(forKey: JSONKey.discount.rawValue) as? String,
              let currency = coder.decodeObject(forKey: JSONKey.currency.rawValue) as? String,
              let duration = coder.decodeObject(forKey: JSONKey.duration.rawValue) as? String else {
            return nil
        }

        self.id = coder.decodeInteger(forKey: JSONKey.id.rawValue)
        self.title = title
        self.descriptionString = description
        self.detailsURLString = detailsURL
        self.priceString = price
        self.discountString = discount
        self.currencyString = currency

        self.startDate = coder.decodeObject(forKey: JSONKey.startDate.rawValue) as? Date
        self.endDate = coder.decodeObject(forKey: JSONKey.endDate.rawValue) as? Date

        self.durationString = duration

        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: JSONKey.id.rawValue)
        coder.encode(self.title, forKey: JSONKey.title.rawValue)
        coder.encode(self.descriptionString, forKey: JSONKey.description.rawValue)
        coder.encode(self.detailsURLString, forKey: JSONKey.detailsURL.rawValue)
        coder.encode(self.priceString, forKey: JSONKey.price.rawValue)
        coder.encode(self.discountString, forKey: JSONKey.discount.rawValue)
        coder.encode(self.currencyString, forKey: JSONKey.currency.rawValue)
        coder.encode(self.startDate, forKey: JSONKey.startDate.rawValue)
        coder.encode(self.endDate, forKey: JSONKey.endDate.rawValue)
        coder.encode(self.durationString, forKey: JSONKey.duration.rawValue)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? SpecializationsCatalogBlockContentItem else {
            return false
        }
        if self === object { return true }
        if type(of: self) != type(of: object) { return false }
        if self.id != object.id { return false }
        if self.title != object.title { return false }
        if self.descriptionString != object.descriptionString { return false }
        if self.detailsURLString != object.detailsURLString { return false }
        if self.priceString != object.priceString { return false }
        if self.discountString != object.discountString { return false }
        if self.currencyString != object.currencyString { return false }
        if self.startDate != object.startDate { return false }
        if self.endDate != object.endDate { return false }
        if self.durationString != object.durationString { return false }
        return true
    }

    enum JSONKey: String {
        case id
        case title
        case description
        case detailsURL = "details_url"
        case price
        case discount
        case currency
        case startDate = "start_date"
        case endDate = "end_date"
        case duration
    }
}
