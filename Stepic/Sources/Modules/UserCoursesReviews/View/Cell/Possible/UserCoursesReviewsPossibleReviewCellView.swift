import SnapKit
import UIKit

extension UserCoursesReviewsPossibleReviewCellView {
    struct Appearance {
        let coverViewSize = CGSize(width: 36, height: 36)
        let coverCornerRadius: CGFloat = 6
        let coverInsets = LayoutInsets.default

        let titleFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let titleTextColor = UIColor.stepikMaterialPrimaryText
        let titleInsets = LayoutInsets.default

        let scoreInsets = LayoutInsets.default
        let scoreClearColor = UIColor.stepikGreenFixed
        let scoreSpacing: CGFloat = 8
        let scoreSize = CGSize(width: 24, height: 24)

        let actionButtonFont = Typography.bodyFont
        let actionButtonTintColor = UIColor.stepikGreenFixed
        let actionButtonInsets = LayoutInsets(top: 10, bottom: 10, right: 16)
    }
}

final class UserCoursesReviewsPossibleReviewCellView: UIView {
    let appearance: Appearance

    private lazy var coverView = CourseWidgetCoverView(
        appearance: .init(cornerRadius: self.appearance.coverCornerRadius)
    )

    private lazy var coverOverlayButton: UIButton = {
        let button = HighlightFakeButton()
        button.addTarget(self, action: #selector(self.coverButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleTextColor
        label.font = self.appearance.titleFont
        label.numberOfLines = 3
        return label
    }()

    private lazy var scoreView: CourseRatingView = {
        var appearance = CourseRatingView.Appearance()
        appearance.starClearColor = self.appearance.scoreClearColor
        appearance.starsSpacing = self.appearance.scoreSpacing
        appearance.starsSize = self.appearance.scoreSize
        let view = CourseRatingView(appearance: appearance)
        view.delegate = self
        return view
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = self.appearance.actionButtonFont
        button.setTitleColor(self.appearance.actionButtonTintColor, for: .normal)
        button.setTitle(NSLocalizedString("UserCoursesReviewsLeaveReview", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(self.actionButtonClicked), for: .touchUpInside)
        return button
    }()

    var onCoverClick: (() -> Void)?
    var onActionButtonClick: (() -> Void)?
    var onScoreDidChange: ((Int) -> Void)?

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

    func configure(viewModel: UserCoursesReviewsItemViewModel?) {
        self.coverView.coverImageURL = viewModel?.coverImageURL
        self.coverView.shouldShowAdaptiveMark = viewModel?.shouldShowAdaptiveMark ?? false
        self.titleLabel.text = viewModel?.title
        self.scoreView.starsCount = viewModel?.score ?? 0
    }

    @objc
    private func coverButtonClicked() {
        self.onCoverClick?()
    }

    @objc
    private func actionButtonClicked() {
        self.onActionButtonClick?()
    }
}

extension UserCoursesReviewsPossibleReviewCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.coverOverlayButton)
        self.addSubview(self.titleLabel)
        self.addSubview(self.scoreView)
        self.addSubview(self.actionButton)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.coverInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.coverInsets.left)
            make.size.equalTo(self.appearance.coverViewSize)
        }

        self.coverOverlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.coverOverlayButton.snp.makeConstraints { $0.edges.equalTo(self.coverView) }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.coverView.snp.top)
            make.leading.equalTo(self.coverView.snp.trailing).offset(self.appearance.titleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
        }

        self.scoreView.translatesAutoresizingMaskIntoConstraints = false
        self.scoreView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.scoreInsets.top)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.lessThanOrEqualTo(self.titleLabel.snp.trailing)
        }

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.top.equalTo(self.scoreView.snp.bottom).offset(self.appearance.actionButtonInsets.top)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.bottom.equalToSuperview().offset(-self.appearance.actionButtonInsets.bottom)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.actionButtonInsets.right)
        }
    }
}

extension UserCoursesReviewsPossibleReviewCellView: CourseRatingViewDelegate {
    func courseRatingView(_ view: CourseRatingView, didSelectStarAtIndex index: Int) {
        self.scoreView.starsCount = index + 1
        self.onScoreDidChange?(self.scoreView.starsCount)
    }
}
