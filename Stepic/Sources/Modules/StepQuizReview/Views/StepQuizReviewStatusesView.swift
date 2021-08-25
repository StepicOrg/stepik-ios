import SnapKit
import UIKit

extension StepQuizReviewStatusesView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let stackViewSpacing: CGFloat = 0

        let joinViewWidth: CGFloat = 2.5
    }
}

final class StepQuizReviewStatusesView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: UIView.noIntrinsicMetric, height: stackViewIntrinsicContentSize.height)
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

    func addArrangedReviewStatus(_ view: StepQuizReviewStatusContainerView) {
        self.stackView.addArrangedSubview(view)
    }

    func removeAllReviewStatuses() {
        self.stackView.removeAllArrangedSubviews()
    }

    func makeReviewStatusesJoined() {
        guard let subviews = self.stackView.arrangedSubviews as? [StepQuizReviewStatusContainerView] else {
            fatalError("Unexpected type of subview")
        }

        let count = subviews.count
        for (idx, subview) in subviews.enumerated() where idx < (count - 1) {
            self.makeJoin(lhs: subview, rhs: subviews[idx + 1])
        }
    }

    private func makeJoin(lhs: StepQuizReviewStatusContainerView, rhs: StepQuizReviewStatusContainerView) {
        let topAnchorView = lhs.anchorView
        let bottomAnchorView = rhs.anchorView

        let joinView = UIView()
        self.insertSubview(joinView, belowSubview: lhs.anchorView)
        joinView.translatesAutoresizingMaskIntoConstraints = false
        joinView.snp.makeConstraints { make in
            make.top.equalTo(topAnchorView.snp.bottom)
            make.centerX.equalTo(topAnchorView.snp.centerX)
            make.width.equalTo(self.appearance.joinViewWidth)
            make.bottom.equalTo(bottomAnchorView.snp.top)
        }

        joinView.backgroundColor = lhs.headerView.status == .completed ? .stepikGreenFixed : .quizReviewPendingBorder
    }
}

extension StepQuizReviewStatusesView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
