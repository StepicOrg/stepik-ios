import SnapKit
import UIKit

protocol CourseWidgetViewProtocol: UIView {
    func configure(viewModel: CourseWidgetViewModel)
}

extension CourseWidgetView {
    struct Appearance {
        let coverViewInsets = LayoutInsets(top: 16, left: 16)
        let coverViewWidthHeight: CGFloat = 80.0

        let titleLabelInsets = LayoutInsets(left: 8, right: 8)

        let badgeImageViewInsets = LayoutInsets(right: 16)
        let badgeImageViewSize = CGSize(width: 18, height: 18)

        let statsViewHeight: CGFloat = 17
        let statsViewInsets = LayoutInsets(top: 8)

        let summaryLabelInsets = LayoutInsets(top: 12, left: 16, bottom: 16, right: 16)
        let priceViewInsets = LayoutInsets(top: 12, bottom: 17)

        let continueLearningButtonInsets = LayoutInsets(top: 16)

        let separatorHeight: CGFloat = 0.5
    }
}

final class CourseWidgetView: UIView, CourseWidgetViewProtocol {
    let appearance: Appearance
    let colorMode: CourseListColorMode

    private lazy var coverView = CourseWidgetCoverView()

    private lazy var titleLabel = CourseWidgetLabel(
        appearance: self.colorMode.courseWidgetTitleLabelAppearance
    )

    private lazy var badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.colorMode.courseWidgetBadgeTintColor
        return imageView
    }()

    private lazy var statsView = CourseWidgetStatsView(
        appearance: self.colorMode.courseWidgetStatsViewAppearance
    )

    private lazy var progressView: CourseWidgetProgressView = {
        let view = CourseWidgetProgressView(appearance: self.colorMode.courseWidgetProgressViewAppearance)
        view.isHidden = true
        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.colorMode.courseWidgetBorderColor
        return view
    }()

    private lazy var summaryLabel = CourseWidgetLabel(
        appearance: self.colorMode.courseWidgetSummaryLabelAppearance
    )

    private lazy var continueLearningButton: CourseWidgetContinueLearningButton = {
        let button = CourseWidgetContinueLearningButton(
            appearance: self.colorMode.courseWidgetContinueLearningButtonAppearance
        )
        button.addTarget(self, action: #selector(self.continueLearningButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var priceView: CourseWidgetPriceView = {
        let view = CourseWidgetPriceView()
        view.isHidden = true
        return view
    }()

    private var badgeImageViewWidthConstraint: Constraint?

    private var summaryLabelLeadingToSuperviewConstraint: Constraint?
    private var summaryLabelLeadingToTitleConstraint: Constraint?

    var onContinueLearningButtonClick: (() -> Void)?

    init(
        frame: CGRect = .zero,
        colorMode: CourseListColorMode = .default,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.colorMode = colorMode
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseWidgetViewModel) {
        self.titleLabel.text = viewModel.title
        self.coverView.coverImageURL = viewModel.coverImageURL
        self.coverView.shouldShowAdaptiveMark = viewModel.isAdaptive

        self.summaryLabel.setTextWithHTMLString(viewModel.summary)
        self.summaryLabel.isHidden = viewModel.isEnrolled
        self.separatorView.isHidden = !viewModel.isEnrolled
        self.continueLearningButton.isHidden = !viewModel.isEnrolled

        self.statsView.learnersLabelText = viewModel.isEnrolled ? nil : viewModel.learnersLabelText
        self.statsView.certificatesLabelText = viewModel.isEnrolled ? nil : viewModel.certificateLabelText
        self.statsView.ratingLabelText = viewModel.isEnrolled ? nil : viewModel.ratingLabelText

        let isArchived = viewModel.userCourse?.isArchived ?? false
        self.statsView.isArchived = isArchived

        self.updateProgressView(viewModel: isArchived ? nil : viewModel.progress)
        self.updatePriceView(viewModel: viewModel.price)
        self.updateBadgeImageView(viewModel: viewModel)
    }

    func updateProgress(viewModel: CourseWidgetProgressViewModel) {
        self.updateProgressView(viewModel: viewModel)
    }

    // MARK: Private API

    private func updateProgressView(viewModel: CourseWidgetProgressViewModel?) {
        if let viewModel = viewModel {
            self.progressView.configure(viewModel: viewModel)
        }
        self.progressView.isHidden = viewModel == nil
    }

    private func updatePriceView(viewModel: CourseWidgetPriceViewModel?) {
        if let viewModel = viewModel, !viewModel.isEnrolled {
            self.summaryLabelLeadingToTitleConstraint?.activate()
            self.summaryLabelLeadingToSuperviewConstraint?.deactivate()

            self.priceView.isHidden = false
            self.priceView.configure(viewModel: viewModel)
        } else {
            self.summaryLabelLeadingToTitleConstraint?.deactivate()
            self.summaryLabelLeadingToSuperviewConstraint?.activate()
            self.priceView.isHidden = true
        }
    }

    private func updateBadgeImageView(viewModel: CourseWidgetViewModel) {
        let badgeImage: UIImage? = {
            if viewModel.isWishlistAvailable {
                let imageName = viewModel.isWishlisted ? "wishlist-like-filled" : "wishlist-like"
                return UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
            } else if let userCourse = viewModel.userCourse {
                return userCourse.isFavorite
                    ? UIImage(named: "course-widget-favorite")?.withRenderingMode(.alwaysTemplate)
                    : nil
            } else {
                return nil
            }
        }()

        self.badgeImageView.image = badgeImage
        self.badgeImageView.isHidden = badgeImage == nil
        self.badgeImageViewWidthConstraint?.update(
            offset: badgeImage != nil ? self.appearance.badgeImageViewSize.width : 0
        )
    }

    @objc
    private func continueLearningButtonClicked() {
        self.onContinueLearningButtonClick?()
    }
}

extension CourseWidgetView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.colorMode.courseWidgetBackgroundColor
    }

    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.badgeImageView)
        self.addSubview(self.statsView)
        self.addSubview(self.progressView)
        self.addSubview(self.summaryLabel)
        self.addSubview(self.priceView)
        self.addSubview(self.continueLearningButton)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.top
                .equalToSuperview()
                .offset(self.appearance.coverViewInsets.top)
            make.leading
                .equalToSuperview()
                .offset(self.appearance.coverViewInsets.left)
            make.height
                .width
                .equalTo(self.appearance.coverViewWidthHeight)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top
                .equalTo(self.coverView.snp.top)
            make.leading
                .equalTo(self.coverView.snp.trailing)
                .offset(self.appearance.titleLabelInsets.left)
            make.trailing
                .equalTo(self.badgeImageView.snp.leading)
                .offset(-self.appearance.titleLabelInsets.right)
        }

        self.badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.badgeImageView.snp.makeConstraints { make in
            make.top
                .equalTo(self.coverView.snp.top)
            make.trailing
                .equalToSuperview()
                .offset(-self.appearance.badgeImageViewInsets.right)
            self.badgeImageViewWidthConstraint = make.width
                .equalTo(self.appearance.badgeImageViewSize.width)
                .constraint
            make.height.equalTo(self.appearance.badgeImageViewSize.height)
        }

        self.statsView.translatesAutoresizingMaskIntoConstraints = false
        self.statsView.snp.makeConstraints { make in
            make.top
                .equalTo(self.titleLabel.snp.bottom)
                .offset(self.appearance.statsViewInsets.top)
                .priority(.low)
            make.leading
                .equalTo(self.titleLabel.snp.leading)
            make.bottom
                .lessThanOrEqualTo(self.coverView.snp.bottom)
            make.trailing
                .equalTo(self.titleLabel.snp.trailing)
            make.height
                .equalTo(self.appearance.statsViewHeight)
        }

        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.snp.makeConstraints { make in
            make.top
                .greaterThanOrEqualTo(self.titleLabel.snp.bottom)
                .offset(self.appearance.statsViewInsets.top)
                .priority(.low)
            make.leading
                .equalTo(self.titleLabel.snp.leading)
            make.bottom
                .equalTo(self.coverView.snp.bottom)
            make.trailing
                .equalTo(self.titleLabel.snp.trailing)
        }

        self.summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.summaryLabel.snp.makeConstraints { make in
            make.top
                .equalTo(self.coverView.snp.bottom)
                .offset(self.appearance.summaryLabelInsets.top)
            make.bottom
                .equalToSuperview()
                .offset(-self.appearance.summaryLabelInsets.bottom)
            make.trailing
                .equalToSuperview()
                .offset(-self.appearance.summaryLabelInsets.right)

            self.summaryLabelLeadingToSuperviewConstraint = make.leading
                .equalToSuperview()
                .offset(self.appearance.summaryLabelInsets.left)
                .constraint
            self.summaryLabelLeadingToTitleConstraint = make.leading.equalTo(self.titleLabel.snp.leading).constraint
            self.summaryLabelLeadingToTitleConstraint?.deactivate()
        }

        self.priceView.translatesAutoresizingMaskIntoConstraints = false
        self.priceView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.coverView.snp.bottom).offset(self.appearance.priceViewInsets.top)
            make.leading.equalTo(self.coverView.snp.leading)
            make.bottom.equalToSuperview().offset(-self.appearance.priceViewInsets.bottom)
            make.trailing.equalTo(self.coverView.snp.trailing)
        }

        self.continueLearningButton.translatesAutoresizingMaskIntoConstraints = false
        self.continueLearningButton.snp.makeConstraints { make in
            make.top
                .equalTo(self.coverView.snp.bottom)
                .offset(self.appearance.continueLearningButtonInsets.top)
            make.leading
                .bottom
                .trailing
                .equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading
                .trailing
                .equalToSuperview()
            make.bottom
                .equalTo(self.continueLearningButton.snp.top)
            make.height
                .equalTo(self.appearance.separatorHeight)
        }
    }
}
