import UIKit

extension UIStatusBarStyle {
    /// A dark status bar, intended for use on light backgrounds.
    static var dark: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
}
