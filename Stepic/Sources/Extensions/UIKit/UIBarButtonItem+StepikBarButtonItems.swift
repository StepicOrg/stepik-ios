import UIKit

extension UIBarButtonItem {
    static func stepikCloseBarButtonItem(target: Any?, action: Selector?) -> UIBarButtonItem {
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

    static func stepikInfoBarButtonItem(target: Any?, action: Selector?) -> UIBarButtonItem {
        let image: UIImage?
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: "info.circle")
        } else {
            image = UIImage(named: "info-system")
        }

        return UIBarButtonItem(image: image, style: .plain, target: target, action: action)
    }

    static func stepikMoreBarButtonItem(target: Any?, action: Selector?) -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: target,
            action: action
        )
    }
}
