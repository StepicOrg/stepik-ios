import Foundation

struct CourseListFilterQuery: Equatable {
    let language: String?
    let isPaid: Bool?
    let withCertificate: Bool?

    var dictValue: JSONDictionary {
        var result: JSONDictionary = [:]

        if let language = self.language {
            result[JSONKey.language.rawValue] = language
        }
        if let isPaid = self.isPaid {
            result[JSONKey.isPaid.rawValue] = isPaid
        }
        if let withCertificate = self.withCertificate {
            result[JSONKey.withCertificate.rawValue] = withCertificate
        }

        return result
    }

    enum JSONKey: String {
        case language
        case isPaid = "is_paid"
        case withCertificate = "with_certificate"
    }
}

extension CourseListFilterQuery {
    init(courseListFilters: [CourseListFilter.Filter]) {
        let flattenedDictionaries = courseListFilters.compactMap { $0.dictValue }.flatMap { $0 }
        let result = Dictionary(uniqueKeysWithValues: flattenedDictionaries)

        self.init(
            language: result[JSONKey.language.rawValue] as? String,
            isPaid: result[JSONKey.isPaid.rawValue] as? Bool,
            withCertificate: result[JSONKey.withCertificate.rawValue] as? Bool
        )
    }
}
