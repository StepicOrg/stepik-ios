import PanModal
import UIKit

extension UIViewController {
    func presentPanModalWithCustomModalPresentationStyle(_ viewControllerToPresent: PanModalPresentable.LayoutType) {
        if DeviceInfo.current.isPad {
            viewControllerToPresent.modalPresentationStyle = .custom
            viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
            viewControllerToPresent.transitioningDelegate = PanModalPresentationDelegate.default
            self.present(viewControllerToPresent, animated: true, completion: nil)
        } else {
            self.presentPanModal(viewControllerToPresent)
        }
    }

    @discardableResult
    func presentIfPanModalWithCustomModalPresentationStyle(_ viewControllerToPresent: UIViewController) -> Bool {
        if let panModalPresentableViewController = viewControllerToPresent as? UIViewController & PanModalPresentable {
            self.presentPanModalWithCustomModalPresentationStyle(panModalPresentableViewController)
            return true
        } else {
            return false
        }
    }
}
