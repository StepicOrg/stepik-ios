import Foundation

enum ProfileMenuBlock: RawRepresentable, Equatable {
    typealias RawValue = String

    case infoHeader
    case notificationsSwitch(isOn: Bool)
    case notificationsTimeSelection
    case certificates
    case description
    case pinsMap
    case achievements
    case userID(id: User.IdType)

    init?(rawValue: RawValue) {
        fatalError("init with raw value has not been implemented")
    }

    var rawValue: RawValue {
        switch self {
        case .infoHeader:
            return "infoHeader"
        case .notificationsSwitch(_):
            return "notificationsSwitch"
        case .notificationsTimeSelection:
            return "notificationsTimeSelection"
        case .certificates:
            return "certificates"
        case .description:
            return "description"
        case .pinsMap:
            return "pinsMap"
        case .achievements:
            return "achievements"
        case .userID(let id):
            return "userID-\(id)"
        }
    }

    static func == (lhs: ProfileMenuBlock, rhs: ProfileMenuBlock) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
