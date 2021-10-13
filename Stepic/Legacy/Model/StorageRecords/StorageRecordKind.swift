import Foundation

enum StorageRecordKind {
    case deadline(courseID: Int)
    case personalOffers
    case wishlist

    var name: String {
        switch self {
        case .deadline(let courseID):
            return "deadline_\(courseID)"
        case .personalOffers:
            return "personal_offers"
        case .wishlist:
            return "wishlist"
        }
    }

    var prefix: PrefixType {
        switch self {
        case .deadline:
            return .deadline
        case .personalOffers:
            return .personalOffers
        case .wishlist:
            return .wishlist
        }
    }

    init?(string: String) {
        if string.hasPrefix(PrefixType.deadline.prefix) {
            let courseIDString = String(string.dropFirst(PrefixType.deadline.prefix.count))
            if let courseID = Int(courseIDString) {
                self = .deadline(courseID: courseID)
                return
            }
        } else if PrefixType(rawValue: string) == .personalOffers {
            self = .personalOffers
            return
        } else if PrefixType(rawValue: string) == .wishlist {
            self = .wishlist
            return
        }
        return nil
    }

    enum PrefixType: String {
        case deadline
        case personalOffers = "personal_offers"
        case wishlist

        var prefix: String {
            switch self {
            case .deadline:
                return "deadline_"
            case .personalOffers:
                return self.rawValue
            case .wishlist:
                return self.rawValue
            }
        }

        var startsWith: String {
            switch self {
            case .deadline:
                return "deadline"
            case .personalOffers:
                return self.rawValue
            case .wishlist:
                return self.rawValue
            }
        }
    }
}
