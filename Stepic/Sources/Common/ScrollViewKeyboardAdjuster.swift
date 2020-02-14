import UIKit

final class ScrollViewKeyboardAdjuster {
    private let scrollView: UIScrollView
    private weak var viewController: UIViewController?
    private var originalContentInset: UIEdgeInsets = .zero
    private var keyboardIsShowing = false

    init(scrollView: UIScrollView, viewController: UIViewController) {
        self.scrollView = scrollView
        self.viewController = viewController

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(self.onKeyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(self.onKeyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Notifications

    @objc
    private func onKeyboardWillShow(notification: NSNotification) {
        guard !keyboardIsShowing,
              let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let viewController = self.viewController else {
            return
        }

        self.keyboardIsShowing = true

        var inset = self.scrollView.contentInset
        self.originalContentInset = inset

        let converted = viewController.view.convert(frame, from: nil)
        let intersection = converted.intersection(frame)
        let bottomInset = intersection.height - viewController.view.safeAreaInsets.bottom

        inset.bottom = bottomInset

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: {
                self.scrollView.contentInset = inset
                self.scrollView.scrollIndicatorInsets = inset
            }
        )
    }

    @objc
    private func onKeyboardWillHide(notification: NSNotification) {
        guard self.keyboardIsShowing,
              let duration = notification
                  .userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }

        self.keyboardIsShowing = false

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: {
                self.scrollView.contentInset = self.originalContentInset
                self.scrollView.scrollIndicatorInsets = self.originalContentInset
            }
        )
    }
}
