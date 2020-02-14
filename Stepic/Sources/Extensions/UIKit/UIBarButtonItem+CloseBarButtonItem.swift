import UIKit

extension UIBarButtonItem {
    static func closeBarButtonItem(target: Any?, action: Selector?) -> UIBarButtonItem {
        if #available(iOS 13.0, *) {
            return UIBarButtonItem(
                barButtonSystemItem: .close,
                target: target,
                action: action
            )
        } else {
            return UIBarButtonItem(
                image: UIImage(named: "navigation-item-button-close"),
                style: .plain,
                target: target,
                action: action
            )
        }
    }
}
