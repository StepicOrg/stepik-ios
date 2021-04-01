import SnapKit
import UIKit

extension CourseInfoHeaderView {
    struct Appearance {
        let actionButtondTitleColor = UIColor.black.withAlphaComponent(0.87)
        let actionButtonHeight: CGFloat = 42.0
        let actionButtonWidthRatio: CGFloat = DeviceInfo.current.isSmallDiagonal ? 0.75 : 0.55

        let actionButtonsStackViewInsets = UIEdgeInsets(top: 10, left: 30, bottom: 15, right: 30)
        let actionButtonsStackViewSpacing: CGFloat = 15.0

        let coverImageViewSize = CGSize(width: 32, height: 32)
        let coverImageViewCornerRadius: CGFloat = 6

        let titleLabelFont = Typography.subheadlineFont
        let titleLabelColor = UIColor.white

        let titleStackViewSpacing: CGFloat = 10
        let titleStackViewInsets = UIEdgeInsets(top: 18, left: 30, bottom: 16, right: 30)

        let marksStackViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
        let marksStackViewSpacing: CGFloat = 10.0

        let statsViewHeight: CGFloat = 17.0

        let verifiedTextColor = UIColor.white
        let verifiedImageSize = CGSize(width: 12, height: 12)
        let verifiedSpacing: CGFloat = 4.0
        let verifiedTextFont = Typography.caption1Font

        let skeletonFirstColor = UIColor.dynamic(light: UIColor(white: 0.99, alpha: 0.95), dark: .skeletonGradientFirst)
        let skeletonSecondColor = UIColor.dynamic(light: UIColor(white: 0.75, alpha: 1), dark: .skeletonGradientSecond)
    }
}

final class CourseInfoHeaderView: UIView {
    let appearance: Appearance

    private let splitTestingService = SplitTestingService(
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
        appearance.defaultTitleColor = self.appearance.actionButtondTitleColor
        let button = ContinueActionButton(mode: .callToAction, appearance: appearance)
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

    var onActionButtonClick: (() -> Void)?
    var onTryForFreeButtonClick: (() -> Void)?

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

    // All elements have fixed height except verified view
    func calculateHeight(hasVerifiedMark: Bool) -> CGFloat {
        let actionButtonsStackViewIntrinsicContentSize = self.actionButtonsStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let verifiedMarkHeight = self.verifiedSignView.appearance.imageViewSize.height
            + self.appearance.marksStackViewSpacing
        return self.appearance.titleStackViewInsets.bottom
            + self.appearance.coverImageViewSize.height
            + self.appearance.marksStackViewInsets.bottom
            + self.appearance.statsViewHeight
            + self.appearance.actionButtonsStackViewInsets.bottom
            + actionButtonsStackViewIntrinsicContentSize.height
            + self.appearance.actionButtonsStackViewInsets.top
            + (hasVerifiedMark ? verifiedMarkHeight : 0)
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

    // MARK: View model

    func configure(viewModel: CourseInfoHeaderViewModel) {
        self.loadImage(url: viewModel.coverImageURL)

        self.titleLabel.text = viewModel.title

        self.statsView.learnersLabelText = viewModel.learnersLabelText
        self.statsView.rating = viewModel.rating
        self.statsView.progress = viewModel.progress

        self.verifiedSignView.isHidden = !viewModel.isVerified

        let shouldShowPromoPriceButton = self.shouldParticipateInPromoPriceSplitTest
            && viewModel.buttonDescription.isCallToAction && viewModel.buttonDescription.isPromo

        self.actionButton.mode = viewModel.buttonDescription.isCallToAction
            ? .callToAction
            : .default
        self.actionButton.setTitle(viewModel.buttonDescription.title, for: .normal)
        self.actionButton.isEnabled = viewModel.buttonDescription.isEnabled
        self.actionButton.isHidden = shouldShowPromoPriceButton

        if shouldShowPromoPriceButton {
            self.promoPriceButton.configure(
                promoPriceString: viewModel.buttonDescription.title,
                fullPriceString: viewModel.buttonDescription.subtitle ?? ""
            )
            self.promoPriceButton.isEnabled = viewModel.buttonDescription.isEnabled
            self.promoPriceButton.isHidden = !shouldShowPromoPriceButton
        }

        self.tryForFreeButton.isHidden = !viewModel.isTryForFreeAvailable
    }

    // MARK: Private methods

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

extension CourseInfoHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.titleStackView.addArrangedSubview(self.coverImageView)
        self.titleStackView.addArrangedSubview(self.titleLabel)

        self.marksStackView.addArrangedSubview(self.statsView)
        self.marksStackView.addArrangedSubview(self.verifiedSignView)

        self.actionButtonsStackView.addArrangedSubview(self.actionButton)
        if self.shouldParticipateInPromoPriceSplitTest {
            self.actionButtonsStackView.addArrangedSubview(self.promoPriceButton)
        }
        self.actionButtonsStackView.addArrangedSubview(self.tryForFreeButton)

        self.addSubview(self.backgroundView)
        self.addSubview(self.actionButtonsStackView)
        self.addSubview(self.titleStackView)
        self.addSubview(self.marksStackView)
    }

    func makeConstraints() {
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.titleStackView.translatesAutoresizingMaskIntoConstraints = false
        self.titleStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(self.appearance.titleStackViewInsets.left)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.titleStackViewInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.titleStackViewInsets.bottom)
        }

        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.coverImageViewSize)
        }

        self.titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.statsView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.statsViewHeight)
        }

        self.marksStackView.translatesAutoresizingMaskIntoConstraints = false
        self.marksStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.titleStackView.snp.top).offset(-self.appearance.marksStackViewInsets.bottom)
        }

        self.actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.actionButtonsStackView.snp.makeConstraints { make in
            make.bottom.equalTo(self.statsView.snp.top).offset(-self.appearance.actionButtonsStackViewInsets.bottom)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(self.appearance.actionButtonsStackViewInsets.left)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.actionButtonsStackViewInsets.right)
        }

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.actionButtonHeight)
            make.width.equalTo(self.snp.width).multipliedBy(self.appearance.actionButtonWidthRatio)
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
    }
}
