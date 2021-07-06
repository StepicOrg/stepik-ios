import SnapKit
import UIKit

extension CourseInfoTabReviewsSummaryDistributionProgressesView {
    struct Appearance {
        let progressViewSecondaryColor = UIColor.stepikGreenFixed.withAlphaComponent(0.12)
        let progressViewMainColor = UIColor.stepikGreenFixed
        let progressViewHeight: CGFloat = 4

        let stackViewSpacing: CGFloat = 8
    }
}

final class CourseInfoTabReviewsSummaryDistributionProgressesView: UIView {
    private static let maxProgressesCount = 5

    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        stackView.distribution = .equalSpacing
        return stackView
    }()

    var progresses: [Float] = Array(
        repeating: 0,
        count: CourseInfoTabReviewsSummaryDistributionProgressesView.maxProgressesCount
    ) {
        didSet {
            self.updateProgresses()
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

    private func updateProgresses() {
        self.stackView.removeAllArrangedSubviews()

        for idx in 0..<Self.maxProgressesCount {
            let progress = self.progresses[safe: idx] ?? 0

            let progressView = UIProgressView()
            progressView.progress = progress
            progressView.trackTintColor = self.appearance.progressViewSecondaryColor
            progressView.progressTintColor = self.appearance.progressViewMainColor

            self.stackView.addArrangedSubview(progressView)
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.snp.makeConstraints { make in
                make.height.equalTo(self.appearance.progressViewHeight)
            }
        }

        self.invalidateIntrinsicContentSize()
    }
}

extension CourseInfoTabReviewsSummaryDistributionProgressesView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateProgresses()
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
