import SnapKit
import UIKit

extension CourseInfoTabReviewsSummaryView {
    struct Appearance {
        let stackViewSpacing: CGFloat = 16
    }
}

final class CourseInfoTabReviewsSummaryView: UIView {
    let appearance: Appearance

    private lazy var ratingView = CourseInfoTabReviewsSummaryRatingView()

    private lazy var progressesView = CourseInfoTabReviewsSummaryDistributionProgressesView()

    private lazy var distributionCountsView = CourseInfoTabReviewsSummaryDistributionCountsView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
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

        self.distributionCountsView.distributions = viewModel.formattedReviewsDistribution

        self.invalidateIntrinsicContentSize()
    }
}

extension CourseInfoTabReviewsSummaryView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.ratingView)
        self.stackView.addArrangedSubview(self.progressesView)
        self.stackView.addArrangedSubview(self.distributionCountsView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.progressesView.translatesAutoresizingMaskIntoConstraints = false
        self.progressesView.snp.makeConstraints { make in
            make.width.greaterThanOrEqualToSuperview().multipliedBy(0.33)
        }
    }
}
