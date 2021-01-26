import Foundation

enum StorageRecordKind {
    case deadline(courseID: Int)

    var name: String {
        switch self {
        case .deadline(let courseID):
            return "deadline_\(courseID)"
        }
    }

    var prefix: PrefixType {
        switch self {
        case .deadline:
            return .deadline
        }
    }

    init?(string: String) {
        if string.hasPrefix(PrefixType.deadline.prefix) {
            let courseIDString = String(string.dropFirst(PrefixType.deadline.prefix.count))
            if let courseID = Int(courseIDString) {
                self = .deadline(courseID: courseID)
                return
            }
        }
        return nil
    }

    enum PrefixType: String {
        case deadline

        var prefix: String {
            switch self {
            case .deadline:
                return "deadline_"
            }
        }

        var startsWith: String {
            switch self {
            case .deadline:
                return "deadline"
            }
        }
    }
}
