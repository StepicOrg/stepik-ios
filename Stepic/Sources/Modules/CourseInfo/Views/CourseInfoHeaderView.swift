import SnapKit
import UIKit

extension CourseInfoHeaderView {
    struct Appearance {
        let actionButtonTitleColor = UIColor.black.withAlphaComponent(0.87)
        let actionButtonHeight: CGFloat = 42.0
        let actionButtonWidthRatio: CGFloat = DeviceInfo.current.isSmallDiagonal ? 0.75 : 0.55
        let actionButtonWishlistWidthRatio: CGFloat = DeviceInfo.current.isSmallDiagonal ? 0.9 : 0.75

        let actionButtonsStackViewSpacing: CGFloat = 16

        let coverImageViewSize = CGSize(width: 32, height: 32)
        let coverImageViewCornerRadius: CGFloat = 6

        let titleLabelFont = Typography.subheadlineFont
        let titleLabelColor = UIColor.white

        let titleStackViewSpacing: CGFloat = 8

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

        return button
    }()

    private lazy var tryForFreeButton: CourseInfoTryForFreeButton = {
        let button = CourseInfoTryForFreeButton()
        button.isHidden = true
        button.addTarget(self, action: #selector(self.tryForFreeButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = self.appearance.actionButtonsStackViewSpacing
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    private lazy var coverImageView: CourseCoverImageView = {
        let view = CourseCoverImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.coverImageViewCornerRadius
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = self.appearance.titleLabelColor
        return label
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

    // Stack view for title and cover
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = self.appearance.titleStackViewSpacing
        stackView.axis = .horizontal
        return stackView
    }()

    private lazy var statsView = CourseInfoStatsView()

    private lazy var unsupportedIAPPurchaseView = QuizFeedbackView()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.contentStackViewSpacing
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private var actionButtonWidthConstraint: Constraint?
    private var actionButtonWishlistWidthConstraint: Constraint?

    var onActionButtonClick: (() -> Void)?
    var onTryForFreeButtonClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        let contentStackViewIntrinsicContentSize = self.contentStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        let height = self.appearance.contentStackViewInsets.top
            + contentStackViewIntrinsicContentSize.height
            + self.appearance.contentStackViewInsets.bottom
        print("CourseInfoHeaderView :: height = \(height)")

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

    func setLoading(_ isLoading: Bool) {
        [
            self.actionButtonsStackView,
            self.titleStackView,
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

    // MARK: Public API

    func configure(viewModel: CourseInfoHeaderViewModel) {
        self.loadImage(url: viewModel.coverImageURL)

        self.titleLabel.text = viewModel.title

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

        if let unsupportedIAPPurchaseText = viewModel.unsupportedIAPPurchaseText {
            self.unsupportedIAPPurchaseView.isHidden = false
            self.unsupportedIAPPurchaseView.update(state: .wrong, title: unsupportedIAPPurchaseText)
            self.unsupportedIAPPurchaseView.setIconImage(
                UIImage(named: "quiz-feedback-info")?.withRenderingMode(.alwaysTemplate)
            )
        } else {
            self.unsupportedIAPPurchaseView.isHidden = true
        }

        self.invalidateIntrinsicContentSize()
    }

    // MARK: Private API

    private func loadImage(url: URL?) {
        self.backgroundView.loadImage(url: url)
        self.coverImageView.loadImage(url: url)
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

        self.titleStackView.addArrangedSubview(self.coverImageView)
        self.titleStackView.addArrangedSubview(self.titleLabel)

        self.contentStackView.addArrangedSubview(self.actionButtonsStackView)
        self.contentStackView.addArrangedSubview(self.marksStackView)
        self.contentStackView.addArrangedSubview(self.titleStackView)
        self.contentStackView.addArrangedSubview(self.unsupportedIAPPurchaseView)

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

        self.titleStackView.translatesAutoresizingMaskIntoConstraints = false
        self.titleStackView.snp.makeConstraints { make in
            make.width.greaterThanOrEqualToSuperview()
        }

        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.coverImageViewSize)
        }

        self.titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.unsupportedIAPPurchaseView.translatesAutoresizingMaskIntoConstraints = false
        self.unsupportedIAPPurchaseView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
    }
}
