import SnapKit
import UIKit

extension CourseInfoTabReviewsSummaryView {
    struct Appearance {
        let stackViewSpacing: CGFloat = 16

        let progressesViewWidthRatio: CGFloat = 0.33
        let progressesViewInsets = LayoutInsets(top: 3.5)

        let distributionCountsViewInsets = LayoutInsets(bottom: -3.5)

        let subtitleLabelFont = Typography.caption1Font
        let subtitleLabelTextColor = UIColor.stepikMaterialSecondaryText
        let subtitleLabelInsets = LayoutInsets.default
    }
}

final class CourseInfoTabReviewsSummaryView: UIView {
    let appearance: Appearance

    private lazy var ratingView = CourseInfoTabReviewsSummaryRatingView()

    private lazy var ratingSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleLabelFont
        label.textColor = self.appearance.subtitleLabelTextColor
        label.numberOfLines = 1
        label.text = NSLocalizedString("CourseInfoTabReviewsOutOfRatingTitle", comment: "")
        return label
    }()

    private lazy var progressesView = CourseInfoTabReviewsSummaryDistributionProgressesView()

    private lazy var progressesContainerView = UIView()

    private lazy var progressesSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleLabelFont
        label.textColor = self.appearance.subtitleLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var distributionCountsView = CourseInfoTabReviewsSummaryDistributionCountsView()

    private lazy var distributionCountsContainerView = UIView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = stackViewIntrinsicContentSize.height
            + self.ratingSubtitleLabel.intrinsicContentSize.height
            + self.appearance.subtitleLabelInsets.top
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: height
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseInfoTabReviewsSummaryViewModel) {
        self.ratingView.title = viewModel.formattedRating
        self.ratingView.starsCount = viewModel.rating

        self.progressesView.progresses = viewModel.reviewsDistribution
            .map { Float($0) / Float(viewModel.reviewsCount) }
            .reversed()
        self.progressesSubtitleLabel.text = viewModel.formattedReviewsCount

        self.distributionCountsView.distributions = viewModel.formattedReviewsDistribution

        self.invalidateIntrinsicContentSize()
    }
}

extension CourseInfoTabReviewsSummaryView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
        self.addSubview(self.ratingSubtitleLabel)
        self.addSubview(self.progressesSubtitleLabel)

        self.progressesContainerView.addSubview(self.progressesView)
        self.distributionCountsContainerView.addSubview(self.distributionCountsView)

        self.stackView.addArrangedSubview(self.ratingView)
        self.stackView.addArrangedSubview(self.progressesContainerView)
        self.stackView.addArrangedSubview(self.distributionCountsContainerView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.progressesView.translatesAutoresizingMaskIntoConstraints = false
        self.progressesView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.progressesViewInsets.edgeInsets)
            make.width.greaterThanOrEqualToSuperview().multipliedBy(self.appearance.progressesViewWidthRatio)
        }

        self.distributionCountsView.translatesAutoresizingMaskIntoConstraints = false
        self.distributionCountsView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.distributionCountsViewInsets.edgeInsets)
        }

        self.ratingSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.ratingSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.stackView.snp.bottom).offset(self.appearance.subtitleLabelInsets.top)
            make.leading.equalTo(self.ratingView.snp.leading)
            make.bottom.equalToSuperview()
        }

        self.progressesSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.progressesSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.stackView.snp.bottom).offset(self.appearance.subtitleLabelInsets.top)
            make.leading.equalTo(self.progressesView.snp.leading)
            make.bottom.equalToSuperview()
        }
    }
}
