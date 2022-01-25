import SnapKit
import UIKit

protocol LessonFinishedDemoPanModalViewDelegate: AnyObject {
    func lessonFinishedDemoPanModalViewDidClickCloseButton(_ view: LessonFinishedDemoPanModalView)
    func lessonFinishedDemoPanModalViewDidClickBuyButton(_ view: LessonFinishedDemoPanModalView)
    func lessonFinishedDemoPanModalViewDidClickWishlistButton(_ view: LessonFinishedDemoPanModalView)
    func lessonFinishedDemoPanModalViewDidClickErrorPlaceholderActionButton(_ view: LessonFinishedDemoPanModalView)
}

extension LessonFinishedDemoPanModalView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let headerImageViewHeight: CGFloat = 136

        let closeButtonWidthHeight: CGFloat = 32
        let closeButtonImageSize = CGSize(width: 24, height: 24)
        let closeButtonInsets = LayoutInsets(top: 8, right: 8)

        let titleLabelFont = UIFont.systemFont(ofSize: 19, weight: .semibold)
        let titleLabelTextColor = UIColor.stepikMaterialPrimaryText

        let subtitleLabelFont = Typography.bodyFont
        let subtitleLabelTextColor = UIColor.stepikMaterialPrimaryText

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets(inset: 16)
    }
}

final class LessonFinishedDemoPanModalView: UIView {
    weak var delegate: LessonFinishedDemoPanModalViewDelegate?

    let appearance: Appearance

    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "finished-demo-lesson-modal-header"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var closeButton: SystemCloseButton = {
        let appearance = SystemCloseButton.Appearance(imageSize: self.appearance.closeButtonImageSize)
        let button = SystemCloseButton(appearance: appearance)
        button.addTarget(self, action: #selector(self.closeButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleLabelFont
        label.textColor = self.appearance.subtitleLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var actionButtonsView: CourseInfoPurchaseModalActionButtonsView = {
        var appearance = CourseInfoPurchaseModalActionButtonsView.Appearance()
        appearance.stackViewInsets = .init(inset: 0)
        let view = CourseInfoPurchaseModalActionButtonsView(appearance: appearance)
        return view
    }()

    private lazy var unsupportedIAPPurchaseView: QuizFeedbackView = {
        let view = QuizFeedbackView()
        view.isHidden = true
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()
    private lazy var contentStackViewContainerView = UIView()

    private lazy var scrollableStackView: ScrollableStackView = {
        let scrollableStackView = ScrollableStackView(orientation: .vertical)
        scrollableStackView.spacing = self.appearance.stackViewSpacing
        return scrollableStackView
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikGray)
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var errorPlaceholderView = StepikPlaceholderView()

    private var errorPlaceholderViewHeightConstraint: Constraint?

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

    func configure(viewModel: LessonFinishedDemoPanModalViewModel) {
        self.titleLabel.text = viewModel.title
        self.subtitleLabel.text = viewModel.subtitle

        let buyButtonViewModel = CourseInfoPurchaseModalPriceViewModel(
            displayPrice: viewModel.displayPrice,
            promoDisplayPrice: viewModel.promoDisplayPrice,
            promoCodeName: nil
        )
        self.actionButtonsView.updateBuyButtonState(newState: .result(buyButtonViewModel))

        let wishlistButtonViewModel = CourseInfoPurchaseModalWishlistViewModel(
            title: viewModel.wishlistTitle,
            isInWishlist: viewModel.isInWishlist,
            isLoading: viewModel.isAddingToWishlist
        )
        self.actionButtonsView.configureWishlistButton(viewModel: wishlistButtonViewModel)

        if let unsupportedIAPPurchaseText = viewModel.unsupportedIAPPurchaseText {
            self.actionButtonsView.buyButtonIsEnabled = false

            self.unsupportedIAPPurchaseView.isHidden = false
            self.unsupportedIAPPurchaseView.update(state: .wrong, title: unsupportedIAPPurchaseText)
            self.unsupportedIAPPurchaseView.setIconImage(
                UIImage(named: "quiz-feedback-info")?.withRenderingMode(.alwaysTemplate)
            )
        } else {
            self.actionButtonsView.buyButtonIsEnabled = true
            self.unsupportedIAPPurchaseView.isHidden = true
        }

        self.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
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

    // MARK: Private API

    private func updateErrorPlaceholderHeight() {
        self.invalidateIntrinsicContentSize()
        let height = floor(self.intrinsicContentSize.height)
        self.errorPlaceholderViewHeightConstraint?.update(offset: height)
    }

    @objc
    private func closeButtonClicked() {
        self.delegate?.lessonFinishedDemoPanModalViewDidClickCloseButton(self)
    }
}

// MARK: - LessonFinishedDemoPanModalView: ProgrammaticallyInitializableViewProtocol -

extension LessonFinishedDemoPanModalView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        self.actionButtonsView.onBuyButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.lessonFinishedDemoPanModalViewDidClickBuyButton(strongSelf)
        }
        self.actionButtonsView.onWishlistButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.lessonFinishedDemoPanModalViewDidClickWishlistButton(strongSelf)
        }
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.addSubview(self.loadingIndicator)
        self.addSubview(self.errorPlaceholderView)
        self.addSubview(self.closeButton)

        self.scrollableStackView.addArrangedView(self.headerImageView)

        self.contentStackViewContainerView.addSubview(self.contentStackView)
        self.scrollableStackView.addArrangedView(self.contentStackViewContainerView)

        self.contentStackView.addArrangedSubview(self.titleLabel)
        self.contentStackView.addArrangedSubview(self.subtitleLabel)
        self.contentStackView.addArrangedSubview(self.unsupportedIAPPurchaseView)
        self.contentStackView.addArrangedSubview(SeparatorView())
        self.contentStackView.addArrangedSubview(self.actionButtonsView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.headerImageView.translatesAutoresizingMaskIntoConstraints = false
        self.headerImageView.snp.makeConstraints { $0.height.equalTo(self.appearance.headerImageViewHeight) }

        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(self.appearance.closeButtonWidthHeight)
            make.top.equalToSuperview().offset(self.appearance.closeButtonInsets.top)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-self.appearance.closeButtonInsets.right)
        }

        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading
                .equalTo(self.contentStackViewContainerView.safeAreaLayoutGuide)
                .offset(self.appearance.stackViewInsets.left)
            make.trailing
                .equalTo(self.contentStackViewContainerView.safeAreaLayoutGuide)
                .offset(-self.appearance.stackViewInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.stackViewInsets.bottom)
        }

        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.4)
        }

        self.errorPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        self.errorPlaceholderView.snp.makeConstraints { make in
            make.centerX.top.leading.trailing.equalToSuperview()
            self.errorPlaceholderViewHeightConstraint = make.height.equalTo(0).constraint
        }
    }
}

// MARK: - LessonFinishedDemoPanModalView: PanModalScrollable -

extension LessonFinishedDemoPanModalView: PanModalScrollable {
    var panScrollable: UIScrollView? { self.scrollableStackView.panScrollable }
}


// MARK: - LessonFinishedDemoPanModalView: StepikPlaceholderViewDelegate -

extension LessonFinishedDemoPanModalView: StepikPlaceholderViewDelegate {
    func buttonDidClick(_ button: UIButton) {
        self.delegate?.lessonFinishedDemoPanModalViewDidClickErrorPlaceholderActionButton(self)
    }
}
