import SnapKit
import UIKit

protocol CourseInfoPurchaseModalViewDelegate: AnyObject {
    func courseInfoPurchaseModalViewDidClickCloseButton(_ view: CourseInfoPurchaseModalView)
    func courseInfoPurchaseModalViewDidClickErrorPlaceholderActionButton(_ view: CourseInfoPurchaseModalView)
    func courseInfoPurchaseModalViewDidRevealPromoCodeInput(_ view: CourseInfoPurchaseModalView)
    func courseInfoPurchaseModalView(_ view: CourseInfoPurchaseModalView, didChangePromoCode promoCode: String)
    func courseInfoPurchaseModalView(_ view: CourseInfoPurchaseModalView, didRequestCheckPromoCode promoCode: String)
    func courseInfoPurchaseModalView(_ view: CourseInfoPurchaseModalView, didClickLink link: URL)
    func courseInfoPurchaseModalViewDidClickBuyButton(_ view: CourseInfoPurchaseModalView)
    func courseInfoPurchaseModalViewDidClickWishlistButton(_ view: CourseInfoPurchaseModalView)
    func courseInfoPurchaseModalViewDidClickRestorePurchaseButton(_ view: CourseInfoPurchaseModalView)
    func courseInfoPurchaseModalViewDidRequestContactSupportOnPurchaseError(_ view: CourseInfoPurchaseModalView)
    func courseInfoPurchaseModalViewDidClickStartLearningButton(_ view: CourseInfoPurchaseModalView)
}

extension CourseInfoPurchaseModalView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets(inset: 16)
    }
}

final class CourseInfoPurchaseModalView: UIView {
    weak var delegate: CourseInfoPurchaseModalViewDelegate?

    let appearance: Appearance

    private lazy var headerView = CourseInfoPurchaseModalHeaderView()

    private lazy var coverView = CourseInfoPurchaseModalCourseCoverView()

    private lazy var promoCodeView = CourseInfoPurchaseModalPromoCodeView()

    private lazy var disclaimerView = CourseInfoPurchaseModalDisclaimerView()

    private lazy var actionButtonsView = CourseInfoPurchaseModalActionButtonsView()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikGray)
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var errorPlaceholderView = StepikPlaceholderView()

    private lazy var purchaseErrorView = CourseInfoPurchaseModalPurchaseErrorView()

    private lazy var purchaseSuccessView = CourseInfoPurchaseModalPurchaseSuccessView()

    private lazy var scrollableStackView: ScrollableStackView = {
        let scrollableStackView = ScrollableStackView(orientation: .vertical)
        scrollableStackView.spacing = self.appearance.stackViewSpacing
        return scrollableStackView
    }()

    private var errorPlaceholderViewHeightConstraint: Constraint?

    private var resultStateContentViews: [UIView] {
        [self.coverView, self.promoCodeView, self.disclaimerView, self.actionButtonsView]
    }

    var contentInsets: UIEdgeInsets {
        get {
            self.scrollableStackView.contentInsets
        }
        set {
            self.scrollableStackView.contentInsets = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        if self.loadingIndicator.isAnimating {
            return CGSize(
                width: UIView.noIntrinsicMetric,
                height: self.loadingIndicator.intrinsicContentSize.height
            )
        }

        let contentSize = self.scrollableStackView.contentSize
        let height = contentSize.height + self.appearance.stackViewSpacing

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateErrorPlaceholderHeight()
    }

    // MARK: Public API

    func configure(viewModel: CourseInfoPurchaseModalViewModel) {
        self.coverView.coverURL = viewModel.courseCoverImageURL
        self.coverView.titleText = viewModel.courseTitle

        if let promoCodeName = viewModel.price.promoCodeName {
            if viewModel.price.promoDisplayPrice != nil {
                self.promoCodeView.state = .success
            } else if self.promoCodeView.state == .idle {
                self.promoCodeView.state = .error
            }
            self.promoCodeView.textFieldText = promoCodeName
        }

        self.actionButtonsView.configureBuyButton(viewModel: viewModel.price)
        self.configure(viewModel: viewModel.wishlist)

        self.purchaseErrorView.courseCoverURL = viewModel.courseCoverImageURL
        self.purchaseErrorView.courseTitle = viewModel.courseTitle

        self.purchaseSuccessView.courseCoverURL = viewModel.courseCoverImageURL
        self.purchaseSuccessView.courseTitle = viewModel.courseTitle

        self.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
    }

    func configure(viewModel: CourseInfoPurchaseModal.CheckPromoCode.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            if data.promoDisplayPrice != nil {
                self.promoCodeView.state = .success
                self.actionButtonsView.configureBuyButton(viewModel: data)
            } else {
                self.promoCodeView.state = .error
            }
        case .error:
            self.promoCodeView.state = .typing
            _ = self.promoCodeView.resignFirstResponder()
        }

        self.actionButtonsView.isUserInteractionEnabled = true
    }

    func configure(viewModel: CourseInfoPurchaseModalWishlistViewModel) {
        self.actionButtonsView.configureWishlistButton(viewModel: viewModel)
    }

    func showLoading() {
        self.scrollableStackView.isHidden = true
        self.loadingIndicator.startAnimating()
    }

    func hideLoading() {
        self.scrollableStackView.isHidden = false
        self.loadingIndicator.stopAnimating()
    }

    func showErrorPlaceholder() {
        self.errorPlaceholderView.set(placeholder: .noConnection)
        self.errorPlaceholderView.delegate = self
        self.errorPlaceholderView.isHidden = false
        self.updateErrorPlaceholderHeight()
    }

    func hideErrorPlaceholder() {
        self.errorPlaceholderView.isHidden = true
    }

    func showPurchaseInProgress() {
        self.isUserInteractionEnabled = false
    }

    func hidePurchaseInProgress() {
        self.isUserInteractionEnabled = true
    }

    func showPurchaseError() {
        self.setPurchaseErrorStateVisible(true)
    }

    func hidePurchaseError() {
        self.setPurchaseErrorStateVisible(false)
    }

    func showPurchaseSuccess() {
        self.setPurchaseSuccessStateVisible(true)
    }

    func hidePurchaseSuccess() {
        self.setPurchaseSuccessStateVisible(false)
    }

    // MARK: Private API

    private func updateErrorPlaceholderHeight() {
        self.invalidateIntrinsicContentSize()
        let height = floor(self.intrinsicContentSize.height)
        self.errorPlaceholderViewHeightConstraint?.update(offset: height)
    }

    private func setPurchaseErrorStateVisible(_ isVisible: Bool) {
        self.purchaseErrorView.isHidden = !isVisible
        self.resultStateContentViews.forEach { $0.isHidden = isVisible }
        self.invalidateIntrinsicContentSize()
    }

    private func setPurchaseSuccessStateVisible(_ isVisible: Bool) {
        self.purchaseSuccessView.isHidden = !isVisible
        self.resultStateContentViews.forEach { $0.isHidden = isVisible }
        self.invalidateIntrinsicContentSize()
    }
}

// MARK: - CourseInfoPurchaseModalView: ProgrammaticallyInitializableViewProtocol -

extension CourseInfoPurchaseModalView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        self.headerView.onCloseClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalViewDidClickCloseButton(strongSelf)
        }

        self.promoCodeView.delegate = self

        self.disclaimerView.onLinkClick = { [weak self] link in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalView(strongSelf, didClickLink: link)
        }

        self.actionButtonsView.onBuyButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalViewDidClickBuyButton(strongSelf)
        }
        self.actionButtonsView.onWishlistButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalViewDidClickWishlistButton(strongSelf)
        }

        self.purchaseErrorView.isHidden = true
        self.purchaseErrorView.onContactSupportClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalViewDidRequestContactSupportOnPurchaseError(strongSelf)
        }
        self.purchaseErrorView.onRestorePurchaseClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalViewDidClickRestorePurchaseButton(strongSelf)
        }

        self.purchaseSuccessView.isHidden = true
        self.purchaseSuccessView.onStartLearningClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalViewDidClickStartLearningButton(strongSelf)
        }
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.addSubview(self.loadingIndicator)
        self.addSubview(self.errorPlaceholderView)

        self.scrollableStackView.addArrangedView(self.headerView)
        self.scrollableStackView.addArrangedView(self.coverView)
        self.scrollableStackView.addArrangedView(self.promoCodeView)
        self.scrollableStackView.addArrangedView(self.disclaimerView)
        self.scrollableStackView.addArrangedView(self.actionButtonsView)
        self.scrollableStackView.addArrangedView(self.purchaseErrorView)
        self.scrollableStackView.addArrangedView(self.purchaseSuccessView)
    }

    func makeConstraints() {
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.4)
        }

        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }

        self.errorPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        self.errorPlaceholderView.snp.makeConstraints { make in
            make.centerX.top.leading.trailing.equalToSuperview()
            self.errorPlaceholderViewHeightConstraint = make.height.equalTo(0).constraint
        }
    }
}

// MARK: - CourseInfoPurchaseModalView: PanModalScrollable -

extension CourseInfoPurchaseModalView: PanModalScrollable {
    var panScrollable: UIScrollView? { self.scrollableStackView.panScrollable }
}

// MARK: - CourseInfoPurchaseModalView: CourseInfoPurchaseModalPromoCodeViewDelegate -

extension CourseInfoPurchaseModalView: CourseInfoPurchaseModalPromoCodeViewDelegate {
    func courseInfoPurchaseModalPromoCodeViewDidRevealInput(_ view: CourseInfoPurchaseModalPromoCodeView) {
        self.invalidateIntrinsicContentSize()
        self.delegate?.courseInfoPurchaseModalViewDidRevealPromoCodeInput(self)
    }

    func courseInfoPurchaseModalPromoCodeView(
        _ view: CourseInfoPurchaseModalPromoCodeView,
        didChangePromoCode promoCode: String
    ) {
        self.delegate?.courseInfoPurchaseModalView(self, didChangePromoCode: promoCode)
    }

    func courseInfoPurchaseModalPromoCodeView(
        _ view: CourseInfoPurchaseModalPromoCodeView,
        didClickCheckPromoCode promoCode: String
    ) {
        self.actionButtonsView.isUserInteractionEnabled = false
        self.delegate?.courseInfoPurchaseModalView(self, didRequestCheckPromoCode: promoCode)
    }
}

// MARK: - CourseInfoPurchaseModalView: StepikPlaceholderViewDelegate -

extension CourseInfoPurchaseModalView: StepikPlaceholderViewDelegate {
    func buttonDidClick(_ button: UIButton) {
        self.delegate?.courseInfoPurchaseModalViewDidClickErrorPlaceholderActionButton(self)
    }
}
