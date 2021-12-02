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

    var anchorModalToLongForm: Bool { false }

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

    func willTransition(to state: PanModalPresentationController.PresentationState) {
        self.currentPresentationState = state

        // Transition from shortForm to longForm
        guard self.isShortFormEnabled, case .longForm = state else {
            return
        }

        self.isShortFormEnabled = false
        self.panModalSetNeedsLayoutUpdate()
    }

    private func updateAdditionalSafeAreaInsets() {
        self.additionalSafeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
    }
}
