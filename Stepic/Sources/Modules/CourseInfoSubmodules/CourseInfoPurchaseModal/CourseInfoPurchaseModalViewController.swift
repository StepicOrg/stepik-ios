import IQKeyboardManagerSwift
import PanModal
import UIKit

protocol CourseInfoPurchaseModalViewControllerProtocol: AnyObject {
    func displayModal(viewModel: CourseInfoPurchaseModal.ModalLoad.ViewModel)
}

final class CourseInfoPurchaseModalViewController: PanModalPresentableViewController {
    private let interactor: CourseInfoPurchaseModalInteractorProtocol

    private var state: CourseInfoPurchaseModal.ViewControllerState

    private var hasLoadedData: Bool {
        if case .result = self.state {
            return true
        }
        return false
    }

    private var keyboardIsShowing = false
    private var keyboardHeight: CGFloat = 0

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
            return self.shortFormHeight
        }

        if self.keyboardIsShowing,
           let intrinsicContentSize = self.courseInfoPurchaseModalView?.intrinsicContentSize {
            return .contentHeight(intrinsicContentSize.height + self.keyboardHeight)
        }

        return super.longFormHeight
    }

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
        switch newState {
        case .result(let viewModel):
            self.courseInfoPurchaseModalView?.hideLoading()
            self.courseInfoPurchaseModalView?.configure(viewModel: viewModel)
        case .loading:
            self.courseInfoPurchaseModalView?.showLoading()
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
}

// MARK: - CourseInfoPurchaseModalViewController: CourseInfoPurchaseModalViewDelegate -

extension CourseInfoPurchaseModalViewController: CourseInfoPurchaseModalViewDelegate {
    func courseInfoPurchaseModalViewDidClickCloseButton(_ view: CourseInfoPurchaseModalView) {
        self.dismiss(animated: true)
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
        print(#function)
    }
}
