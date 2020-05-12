import UIKit

extension UIModalPresentationStyle {
    var isSheetStyle: Bool {
        if #available(iOS 13.0, *) {
            if self == .automatic {
                return true
            }
        }

        switch self {
        case .pageSheet, .formSheet:
            return true
        default:
            return false
        }
    }

    static var stepikAutomatic: UIModalPresentationStyle {
        if #available(iOS 13.0, *) {
            return .automatic
        } else {
            return .fullScreen
        }
    }
}
