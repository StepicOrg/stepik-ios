import Foundation

struct SubmissionsFilterQuery {
    var user: User.IdType?
    var status: String?
    var order: Order?
    var reviewStatus: String?
    var search: String?

    static var `default`: SubmissionsFilterQuery { SubmissionsFilterQuery(order: .desc) }

    init(
        user: User.IdType? = nil,
        status: String? = nil,
        order: Order? = nil,
        reviewStatus: String? = nil,
        search: String? = nil
    ) {
        self.user = user
        self.status = status
        self.order = order
        self.reviewStatus = reviewStatus
        self.search = search
    }

    var dictValue: JSONDictionary {
        var result: JSONDictionary = [:]

        if let user = self.user {
            result[JSONKey.user.rawValue] = user
        }

        if let status = self.status {
            result[JSONKey.status.rawValue] = status
        }

        if let order = self.order {
            result[JSONKey.order.rawValue] = order.rawValue
        }

        if let reviewStatus = self.reviewStatus {
            result[JSONKey.reviewStatus.rawValue] = reviewStatus
        }

        if let search = self.search {
            result[JSONKey.search.rawValue] = search
        }

        return result
    }

    enum Order: String {
        case asc
        case desc
    }

    enum JSONKey: String {
        case user
        case status
        case order
        case search
        case reviewStatus = "review_status"
    }
}

extension SubmissionsFilterQuery {
    init(filters: [SubmissionsFilter.Filter]) {
        let flattenedDictionaries = filters.compactMap { $0.dictValue }.flatMap { $0 }
        let result = Dictionary(uniqueKeysWithValues: flattenedDictionaries)

        let order = { () -> Order? in
            if let stringValue = result[JSONKey.order.rawValue] as? String {
                return Order(rawValue: stringValue)
            }
            return nil
        }()

        self.init(
            user: nil,
            status: result[JSONKey.status.rawValue] as? String,
            order: order,
            reviewStatus: result[JSONKey.reviewStatus.rawValue] as? String,
            search: nil
        )
    }
}
