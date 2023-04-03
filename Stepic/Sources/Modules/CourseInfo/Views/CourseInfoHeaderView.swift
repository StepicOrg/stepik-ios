import SnapKit
import UIKit

extension CourseInfoHeaderView {
    struct Appearance {
        let actionButtonTitleColor = UIColor.black.withAlphaComponent(0.87)
        let actionButtonHeight: CGFloat = 42.0
        let actionButtonWidthRatio: CGFloat = DeviceInfo.current.isSmallDiagonal ? 0.75 : 0.55
        let actionButtonWishlistWidthRatio: CGFloat = DeviceInfo.current.isSmallDiagonal ? 0.9 : 0.75

        let actionButtonsStackViewSpacing: CGFloat = 16

        let marksStackViewSpacing: CGFloat = 8

        let statsViewHeight: CGFloat = 17

        let verifiedTextColor = UIColor.white
        let verifiedImageSize = CGSize(width: 12, height: 12)
        let verifiedSpacing: CGFloat = 4
        let verifiedTextFont = Typography.caption1Font

        let contentStackViewSpacing: CGFloat = 16
        let contentStackViewInsets = UIEdgeInsets(top: 16, left: 30, bottom: 16, right: 30)

        let skeletonFirstColor = UIColor.dynamic(light: UIColor(white: 0.99, alpha: 0.95), dark: .skeletonGradientFirst)
        let skeletonSecondColor = UIColor.dynamic(light: UIColor(white: 0.75, alpha: 1), dark: .skeletonGradientSecond)
    }
}

final class CourseInfoHeaderView: UIView {
    let appearance: Appearance

    private let splitTestingService: SplitTestingServiceProtocol = SplitTestingService(
        analyticsService: AnalyticsUserProperties(),
        storage: UserDefaults.standard
    )

    private var shouldParticipateInPromoPriceSplitTest: Bool {
        DiscountAppearanceSplitTest.shouldParticipate
    }

    private lazy var backgroundView: CourseInfoBlurredBackgroundView = {
        let view = CourseInfoBlurredBackgroundView()
        // To prevent tap handling
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var actionButton: ContinueActionButton = {
        var appearance = ContinueActionButton.Appearance()
        appearance.defaultTitleColor = self.appearance.actionButtonTitleColor
        let button = ContinueActionButton(mode: .callToActionGreen, appearance: appearance)
        button.addTarget(self, action: #selector(self.actionButtonClicked), for: .touchUpInside)
        button.accessibilityIdentifier = "actionButton"
        return button
    }()

    private lazy var promoPriceButton: PromoPriceButtonProtocol = {
        let splitTest = self.splitTestingService.fetchSplitTest(DiscountAppearanceSplitTest.self)

        let button: PromoPriceButtonProtocol
        switch splitTest.currentGroup {
        case .discountTransparent:
            button = TransparentPromoPriceButton()
        case .discountGreen:
            button = PromoPriceButton(style: .green)
        case .discountPurple:
            button = PromoPriceButton(style: .purple)
        }

        button.addTarget(self, action: #selector(self.actionButtonClicked), for: .touchUpInside)
        button.isHidden = true
        button.accessibilityIdentifier = "promoPriceButton"

        return button
    }()

    private lazy var tryForFreeButton: CourseInfoTryForFreeButton = {
        let button = CourseInfoTryForFreeButton()
        button.isHidden = true
        button.addTarget(self, action: #selector(self.tryForFreeButtonClicked), for: .touchUpInside)
        button.accessibilityIdentifier = "tryForFreeButton"
        return button
    }()

    private lazy var actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = self.appearance.actionButtonsStackViewSpacing
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    private lazy var verifiedSignView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.iconSpacing = self.appearance.verifiedSpacing
        appearance.imageViewSize = self.appearance.verifiedImageSize
        appearance.textColor = self.appearance.verifiedTextColor
        appearance.font = self.appearance.verifiedTextFont
        let view = CourseWidgetStatsItemView(appearance: appearance)
        view.image = UIImage(named: "course-info-verified")
        view.text = NSLocalizedString("CourseMeetsRecommendations", comment: "")
        return view
    }()

    // Stack view for stat items (learners, rating, ...) and "verified" mark
    private lazy var marksStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = self.appearance.marksStackViewSpacing
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    private lazy var statsView = CourseInfoStatsView()

    private lazy var titleView = CourseInfoHeaderTitleView()

    private lazy var purchaseFeedbackView: CourseInfoPurchaseFeedbackView = {
        let view = CourseInfoPurchaseFeedbackView()
        view.isHidden = true
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.contentStackViewSpacing
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private var actionButtonWidthConstraint: Constraint?
    private var actionButtonWishlistWidthConstraint: Constraint?

    var onActionButtonClick: (() -> Void)?
    var onTryForFreeButtonClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        self.titleView.invalidateIntrinsicContentSize()

        let contentStackViewIntrinsicContentSize = self.contentStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        let height = self.appearance.contentStackViewInsets.top
            + contentStackViewIntrinsicContentSize.height
            + self.appearance.contentStackViewInsets.bottom

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertedPoint = self.convert(point, to: self.actionButtonsStackView)

        if self.actionButtonsStackView.bounds.contains(convertedPoint) {
            for subview in self.actionButtonsStackView.arrangedSubviews {
                let shouldSubviewInteract = !subview.isHidden && subview.isUserInteractionEnabled
                if shouldSubviewInteract && subview.frame.contains(convertedPoint) {
                    return subview
                }
            }
        }

        return nil
    }

    // MARK: Public API

    func setLoading(_ isLoading: Bool) {
        [
            self.actionButtonsStackView,
            self.titleView,
            self.marksStackView
        ].forEach { $0.isHidden = isLoading }

        if isLoading {
            self.skeleton.firstColor = self.appearance.skeletonFirstColor
            self.skeleton.secondColor = self.appearance.skeletonSecondColor
            self.skeleton.viewBuilder = { CourseInfoHeaderSkeletonView() }
            self.skeleton.show()
        } else {
            self.skeleton.hide()
        }
    }

    func configure(viewModel: CourseInfoHeaderViewModel) {
        self.loadImage(url: viewModel.coverImageURL)
        self.titleView.title = viewModel.title

        self.statsView.learnersLabelText = viewModel.learnersLabelText
        self.statsView.rating = viewModel.rating
        self.statsView.progress = viewModel.progress

        self.verifiedSignView.isHidden = !viewModel.isVerified

        let shouldShowPromoPriceButton = self.shouldParticipateInPromoPriceSplitTest
            && viewModel.buttonDescription.isCallToAction && viewModel.buttonDescription.isPromo

        self.actionButton.mode = {
            if viewModel.buttonDescription.isWishlist {
                return .callToActionViolet
            }
            return viewModel.buttonDescription.isCallToAction ? .callToActionGreen : .default
        }()
        self.actionButton.setTitle(viewModel.buttonDescription.title, for: .normal)
        self.actionButton.isEnabled = viewModel.buttonDescription.isEnabled
        self.actionButton.isHidden = shouldShowPromoPriceButton

        if viewModel.buttonDescription.isWishlist {
            self.actionButtonWidthConstraint?.deactivate()
            self.actionButtonWishlistWidthConstraint?.activate()
        } else {
            self.actionButtonWishlistWidthConstraint?.deactivate()
            self.actionButtonWidthConstraint?.activate()
        }

        if shouldShowPromoPriceButton {
            self.promoPriceButton.configure(
                promoPriceString: viewModel.buttonDescription.title,
                fullPriceString: viewModel.buttonDescription.subtitle ?? ""
            )
            self.promoPriceButton.isEnabled = viewModel.buttonDescription.isEnabled
            self.promoPriceButton.isHidden = false
        } else {
            self.promoPriceButton.isHidden = true
        }

        self.tryForFreeButton.isHidden = !viewModel.isTryForFreeAvailable

        if let purchaseFeedbackText = viewModel.purchaseFeedbackText {
            self.purchaseFeedbackView.isHidden = false
            self.purchaseFeedbackView.set(title: purchaseFeedbackText)
        } else {
            self.purchaseFeedbackView.isHidden = true
        }

        self.invalidateIntrinsicContentSize()
    }

    // MARK: Private API

    private func loadImage(url: URL?) {
        self.backgroundView.loadImage(url: url)
        self.titleView.coverImageURL = url
    }

    @objc
    private func actionButtonClicked() {
        self.onActionButtonClick?()
    }

    @objc
    private func tryForFreeButtonClicked() {
        self.onTryForFreeButtonClick?()
    }
}

// MARK: - CourseInfoHeaderView: ProgrammaticallyInitializableViewProtocol -

extension CourseInfoHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.actionButtonsStackView.addArrangedSubview(self.actionButton)
        if self.shouldParticipateInPromoPriceSplitTest {
            self.actionButtonsStackView.addArrangedSubview(self.promoPriceButton)
        }
        self.actionButtonsStackView.addArrangedSubview(self.tryForFreeButton)

        self.marksStackView.addArrangedSubview(self.statsView)
        self.marksStackView.addArrangedSubview(self.verifiedSignView)

        self.contentStackView.addArrangedSubview(self.actionButtonsStackView)
        self.contentStackView.addArrangedSubview(self.marksStackView)
        self.contentStackView.addArrangedSubview(self.titleView)
        self.contentStackView.addArrangedSubview(self.purchaseFeedbackView)

        self.addSubview(self.backgroundView)
        self.addSubview(self.contentStackView)
    }

    func makeConstraints() {
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(self.appearance.contentStackViewInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.contentStackViewInsets.bottom)
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(self.appearance.contentStackViewInsets)
        }

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.actionButtonHeight)

            self.actionButtonWidthConstraint = make.width
                .equalTo(self.snp.width)
                .multipliedBy(self.appearance.actionButtonWidthRatio)
                .constraint

            self.actionButtonWishlistWidthConstraint = make.width
                .equalTo(self.snp.width)
                .multipliedBy(self.appearance.actionButtonWishlistWidthRatio)
                .constraint
            self.actionButtonWishlistWidthConstraint?.deactivate()
        }

        if self.shouldParticipateInPromoPriceSplitTest {
            self.promoPriceButton.translatesAutoresizingMaskIntoConstraints = false
            self.promoPriceButton.snp.makeConstraints { make in
                make.height.equalTo(self.appearance.actionButtonHeight)
                make.width
                    .equalTo(self.snp.width)
                    .multipliedBy(self.appearance.actionButtonWidthRatio)
                    .priority(.low)
            }
        }

        self.statsView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.statsViewHeight)
        }

        self.purchaseFeedbackView.translatesAutoresizingMaskIntoConstraints = false
        self.purchaseFeedbackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
    }
}
