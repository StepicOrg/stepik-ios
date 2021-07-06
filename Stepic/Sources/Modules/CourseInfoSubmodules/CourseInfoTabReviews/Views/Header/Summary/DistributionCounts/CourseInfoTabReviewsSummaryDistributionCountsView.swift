import SnapKit
import UIKit

extension CourseInfoTabReviewsSummaryDistributionCountsView {
    struct Appearance {
        let stackViewSpacing: CGFloat = 0
    }
}

final class CourseInfoTabReviewsSummaryDistributionCountsView: UIView {
    private static let maxDistributionsCount = 5

    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    var distributions = Array(
        repeating: "",
        count: CourseInfoTabReviewsSummaryDistributionCountsView.maxDistributionsCount
    ) {
        didSet {
            self.updateDistributions()
        }
    }

    override var intrinsicContentSize: CGSize {
        self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
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

    private func updateDistributions() {
        self.stackView.removeAllArrangedSubviews()

        for (idx, distribution) in self.distributions.prefix(Self.maxDistributionsCount).enumerated().reversed() {
            let itemView = CourseInfoTabReviewsSummaryDistributionCountItemView()
            itemView.title = distribution
            itemView.starsCount = idx + 1
            self.stackView.addArrangedSubview(itemView)
        }

        self.invalidateIntrinsicContentSize()
    }
}

extension CourseInfoTabReviewsSummaryDistributionCountsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateDistributions()
    }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
