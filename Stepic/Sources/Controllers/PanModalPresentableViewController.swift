import PanModal
import UIKit

class PanModalPresentableViewController: UIViewController, PanModalPresentable {
    var panScrollable: UIScrollView? { nil }

    var shortFormHeight: PanModalHeight {
        self.isShortFormEnabled
            ? .contentHeight(floor(UIScreen.main.bounds.height / 3))
            : self.longFormHeight
    }

    var longFormHeight: PanModalHeight {
        guard let scrollView = self.panScrollable else {
            return .maxHeight
        }

        scrollView.layoutIfNeeded()
        return .contentHeight(scrollView.contentSize.height)
    }

    var cornerRadius: CGFloat { 8.0 }

    var springDamping: CGFloat { 0.8 }

    var transitionAnimationOptions: UIView.AnimationOptions {
        [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]
    }

    var panModalBackgroundColor: UIColor { .black.withAlphaComponent(0.7) }

    var dragIndicatorBackgroundColor: UIColor { .lightGray }

    var anchorModalToLongForm: Bool { false }

    var allowsDragToDismiss: Bool { true }

    var allowsTapToDismiss: Bool { true }

    var isUserInteractionEnabled: Bool { true }

    var isHapticFeedbackEnabled: Bool { true }

    var shouldRoundTopCorners: Bool { self.isPanModalPresented }

    var showDragIndicator: Bool { self.shouldRoundTopCorners }

    var isShortFormEnabled = true

    var currentPresentationState: PanModalPresentationController.PresentationState?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateAdditionalSafeAreaInsets()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(
            alongsideTransition: { _ in
                self.updateAdditionalSafeAreaInsets()
            },
            completion: nil
        )
    }

    func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool { true }

    func willRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) {}

    func shouldTransition(to state: PanModalPresentationController.PresentationState) -> Bool { true }

    func shouldPrioritize(panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool { false }

    func willTransition(to state: PanModalPresentationController.PresentationState) {
        self.currentPresentationState = state

        // Transition from shortForm to longForm
        guard self.isShortFormEnabled, case .longForm = state else {
            return
        }

        self.isShortFormEnabled = false
        self.panModalSetNeedsLayoutUpdate()
    }

    func panModalWillDismiss() {}

    func panModalDidDismiss() {}

    private func updateAdditionalSafeAreaInsets() {
        self.additionalSafeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
    }
}
