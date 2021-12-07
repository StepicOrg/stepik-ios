import IQKeyboardManagerSwift
import PanModal
import SVProgressHUD
import UIKit

protocol CourseInfoPurchaseModalViewControllerProtocol: AnyObject {
    func displayModal(viewModel: CourseInfoPurchaseModal.ModalLoad.ViewModel)
    func displayCheckPromoCodeResult(viewModel: CourseInfoPurchaseModal.CheckPromoCode.ViewModel)
    func displayAddCourseToWishlistResult(viewModel: CourseInfoPurchaseModal.AddCourseToWishlist.ViewModel)
}

final class CourseInfoPurchaseModalViewController: PanModalPresentableViewController {
    private let interactor: CourseInfoPurchaseModalInteractorProtocol

    private var state: CourseInfoPurchaseModal.ViewControllerState

    private var hasLoadedData: Bool {
        switch self.state {
        case .loading, .error:
            return false
        default:
            return true
        }
    }

    private var keyboardIsShowing = false
    private var keyboardHeight: CGFloat = 0

    private var isPurchaseInProgress = false

    var courseInfoPurchaseModalView: CourseInfoPurchaseModalView? { self.view as? CourseInfoPurchaseModalView }

    override var panScrollable: UIScrollView? {
        // Returns nil to prevent PanModal overrides scrollView bottom contentInset.
        self.keyboardIsShowing ? nil : self.courseInfoPurchaseModalView?.panScrollable
    }

    override var shortFormHeight: PanModalHeight {
        if self.hasLoadedData && self.isShortFormEnabled,
           let intrinsicContentSize = self.courseInfoPurchaseModalView?.intrinsicContentSize {
            return .contentHeight(intrinsicContentSize.height)
        }
        return super.shortFormHeight
    }

    override var longFormHeight: PanModalHeight {
        guard self.hasLoadedData else {
            return super.longFormHeight
        }

        if self.keyboardIsShowing,
           let intrinsicContentSize = self.courseInfoPurchaseModalView?.intrinsicContentSize {
            return .contentHeight(intrinsicContentSize.height + self.keyboardHeight)
        }

        return super.longFormHeight
    }

    override var allowsDragToDismiss: Bool { !self.isPurchaseInProgress }

    override var allowsTapToDismiss: Bool { !self.isPurchaseInProgress }

    init(
        interactor: CourseInfoPurchaseModalInteractorProtocol,
        initialState: CourseInfoPurchaseModal.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseInfoPurchaseModalView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onKeyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onKeyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        self.updateState(newState: self.state)
        self.interactor.doModalLoad(request: .init())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        IQKeyboardManager.shared.enable = true
    }

    // MARK: Private API

    private func updateState(newState: CourseInfoPurchaseModal.ViewControllerState) {
        self.courseInfoPurchaseModalView?.hideLoading()
        self.courseInfoPurchaseModalView?.hideErrorPlaceholder()

        self.isPurchaseInProgress = false
        self.courseInfoPurchaseModalView?.hidePurchaseInProgress()

        self.courseInfoPurchaseModalView?.hidePurchaseError()

        switch newState {
        case .loading:
            self.courseInfoPurchaseModalView?.showLoading()
        case .error:
            self.courseInfoPurchaseModalView?.showErrorPlaceholder()
        case .result(let viewModel):
            self.courseInfoPurchaseModalView?.configure(viewModel: viewModel)
        case .purchaseInProgress:
            self.isPurchaseInProgress = true
            self.courseInfoPurchaseModalView?.showPurchaseInProgress()
        case .purchaseErrorAppStore:
            fatalError("not implemented")
        case .purchaseErrorStepik:
            self.courseInfoPurchaseModalView?.showPurchaseError()
            self.transition(to: .longForm)
        case .purchaseSuccess:
            fatalError("not implemented")
        }

        self.state = newState
    }

    private func transition(to state: PanModalPresentationController.PresentationState) {
        self.panModalSetNeedsLayoutUpdate()
        self.panModalTransition(to: state)
    }

    @objc
    private func onKeyboardWillShow(notification: NSNotification) {
        self.keyboardIsShowing = true

        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        self.keyboardHeight = keyboardFrame?.size.height ?? 0

        var newContentInsets = self.courseInfoPurchaseModalView?.contentInsets ?? .zero
        newContentInsets.bottom = self.keyboardHeight
        self.courseInfoPurchaseModalView?.contentInsets = newContentInsets

        self.transition(to: .longForm)
    }

    @objc
    private func onKeyboardWillHide(notification: NSNotification) {
        self.keyboardIsShowing = false
        self.isShortFormEnabled = true
        self.transition(to: .shortForm)
    }
}

// MARK: - CourseInfoPurchaseModalViewController: CourseInfoPurchaseModalViewControllerProtocol -

extension CourseInfoPurchaseModalViewController: CourseInfoPurchaseModalViewControllerProtocol {
    func displayModal(viewModel: CourseInfoPurchaseModal.ModalLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
        self.transition(to: .shortForm)
    }

    func displayCheckPromoCodeResult(viewModel: CourseInfoPurchaseModal.CheckPromoCode.ViewModel) {
        if case .error = viewModel.state {
            SVProgressHUD.showError(
                withStatus: NSLocalizedString("CourseInfoPurchaseModalCheckPromoCodeStateError", comment: "")
            )
        }

        self.courseInfoPurchaseModalView?.configure(viewModel: viewModel)
    }

    func displayAddCourseToWishlistResult(viewModel: CourseInfoPurchaseModal.AddCourseToWishlist.ViewModel) {
        switch viewModel.state {
        case .loading(let viewModel):
            self.courseInfoPurchaseModalView?.configure(viewModel: viewModel)
        case .error(let message):
            SVProgressHUD.showError(withStatus: message)
        case .result(let message, let viewModel):
            SVProgressHUD.showSuccess(withStatus: message)
            self.courseInfoPurchaseModalView?.configure(viewModel: viewModel)
        }
    }
}

// MARK: - CourseInfoPurchaseModalViewController: CourseInfoPurchaseModalViewDelegate -

extension CourseInfoPurchaseModalViewController: CourseInfoPurchaseModalViewDelegate {
    func courseInfoPurchaseModalViewDidClickCloseButton(_ view: CourseInfoPurchaseModalView) {
        self.dismiss(animated: true)
    }

    func courseInfoPurchaseModalViewDidClickErrorPlaceholderActionButton(_ view: CourseInfoPurchaseModalView) {
        self.updateState(newState: .loading)
        self.interactor.doModalLoad(request: .init())
    }

    func courseInfoPurchaseModalViewDidRevealPromoCodeInput(_ view: CourseInfoPurchaseModalView) {
        if let currentPresentationState = self.currentPresentationState {
            self.transition(to: currentPresentationState)
        }
    }

    func courseInfoPurchaseModalView(_ view: CourseInfoPurchaseModalView, didChangePromoCode promoCode: String) {
        self.interactor.doPromoCodeDidChange(request: .init(promoCode: promoCode))
    }

    func courseInfoPurchaseModalView(_ view: CourseInfoPurchaseModalView, didRequestCheckPromoCode promoCode: String) {
        self.interactor.doCheckPromoCode(request: .init(promoCode: promoCode))
    }

    func courseInfoPurchaseModalView(_ view: CourseInfoPurchaseModalView, didClickLink link: URL) {
        WebControllerManager.shared.presentWebControllerWithURL(
            link,
            inController: self,
            withKey: .externalLink,
            allowsSafari: true,
            backButtonStyle: .done
        )
    }

    func courseInfoPurchaseModalViewDidClickBuyButton(_ view: CourseInfoPurchaseModalView) {
        print(#function)
    }

    func courseInfoPurchaseModalViewDidClickWishlistButton(_ view: CourseInfoPurchaseModalView) {
        self.interactor.doWishlistMainAction(request: .init())
    }

    func courseInfoPurchaseModalViewDidClickRestorePurchaseButton(_ view: CourseInfoPurchaseModalView) {
        print(#function)
    }

    func courseInfoPurchaseModalViewDidRequestContactSupportOnPurchaseError(_ view: CourseInfoPurchaseModalView) {
        print(#function)
    }
}
