import UIKit

extension UIActivityIndicatorView.Style {
    static var stepikWhiteLarge: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .large
        } else {
            return .whiteLarge
        }
    }

    static var stepikWhite: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .medium
        } else {
            return .white
        }
    }

    static var stepikGray: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .medium
        } else {
            return .gray
        }
    }
}
