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
}
