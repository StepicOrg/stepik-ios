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

struct PlatformOptionSet: OptionSet {
    let rawValue: Int

    static let web = PlatformOptionSet(rawValue: 1 << 0)
    static let mobile = PlatformOptionSet(rawValue: 1 << 1)
    static let sunionPlugin = PlatformOptionSet(rawValue: 1 << 2)
    static let android = PlatformOptionSet(rawValue: 1 << 3)
    static let ios = PlatformOptionSet(rawValue: 1 << 4)

    static let mobileiOS: PlatformOptionSet = [.mobile, .ios]

    var stringValue: String {
        var platforms = [PlatformType]()

        if self.contains(.web) {
            platforms.append(.web)
        } else if self.contains(.mobile) {
            platforms.append(.mobile)
        } else if self.contains(.sunionPlugin) {
            platforms.append(.sunionPlugin)
        } else if self.contains(.android) {
            platforms.append(.android)
        } else if self.contains(.ios) {
            platforms.append(.ios)
        }

        return platforms.map(\.stringValue).joined(separator: ",")
    }
}
