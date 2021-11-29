import Foundation

enum PlatformType: Int {
    case web = 1
    case mobile
    case sunionPlugin
    case android
    case ios

    var stringValue: String {
        switch self {
        case .web:
            return "web"
        case .mobile:
            return "mobile"
        case .sunionPlugin:
            return "sunion_plugin"
        case .android:
            return "android"
        case .ios:
            return "ios"
        }
    }
}

extension PlatformType {
    init?(_ value: String) {
        switch value {
        case "web":
            self = .web
        case "mobile":
            self = .mobile
        case "sunion_plugin":
            self = .sunionPlugin
        case "android":
            self = .android
        case "ios":
            self = .ios
        default:
            return nil
        }
    }
}

struct PlatformOptionSet: OptionSet {
    let rawValue: Int

    static let web = PlatformOptionSet(rawValue: 1 << 0)
    static let mobile = PlatformOptionSet(rawValue: 1 << 1)
    static let sunionPlugin = PlatformOptionSet(rawValue: 1 << 2)
    static let android = PlatformOptionSet(rawValue: 1 << 3)
    static let ios = PlatformOptionSet(rawValue: 1 << 4)

    static let mobileIOS: PlatformOptionSet = [.mobile, .ios]

    var stringValue: String {
        var platforms = [PlatformType]()

        if self.contains(.web) {
            platforms.append(.web)
        }
        if self.contains(.mobile) {
            platforms.append(.mobile)
        }
        if self.contains(.sunionPlugin) {
            platforms.append(.sunionPlugin)
        }
        if self.contains(.android) {
            platforms.append(.android)
        }
        if self.contains(.ios) {
            platforms.append(.ios)
        }

        return platforms.map(\.stringValue).joined(separator: ",")
    }
}
