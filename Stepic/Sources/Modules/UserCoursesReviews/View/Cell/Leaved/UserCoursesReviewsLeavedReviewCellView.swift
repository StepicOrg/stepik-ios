import SnapKit
import UIKit

extension UserCoursesReviewsLeavedReviewCellView {
    struct Appearance {
        let coverViewSize = CGSize(width: 36, height: 36)
        let coverCornerRadius: CGFloat = 6
        let coverInsets = LayoutInsets.default

        let titleFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let titleTextColor = UIColor.stepikMaterialPrimaryText
        let titleInsets = LayoutInsets.default

        let moreButtonSize = CGSize(width: 26, height: 26)
        let moreButtonTintColor = UIColor.stepikMaterialSecondaryText
        let moreButtonInsets = LayoutInsets.default

        let textLabelFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let textLabelTextColor = UIColor.stepikMaterialSecondaryText
        let textLabelInsets = LayoutInsets(top: 8)

        let dateLabelFont = Typography.caption1Font
        let dateLabelTextColor = UIColor.stepikMaterialSecondaryText
        let dateLabelInsets = LayoutInsets(top: 8)

        let scoreClearStarsColor = UIColor.onSurface.withAlphaComponent(0.12)
        let scoreInsets = LayoutInsets(top: 8, bottom: 16)
    }
}

final class UserCoursesReviewsLeavedReviewCellView: UIView {
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

    private lazy var moreButton: UIButton = {
        let image = UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = self.appearance.moreButtonTintColor
        button.addTarget(self, action: #selector(self.moreButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.textLabelTextColor
        label.font = self.appearance.textLabelFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var scoreView: CourseRatingView = {
        var appearance = CourseRatingView.Appearance()
        appearance.starClearColor = self.appearance.scoreClearStarsColor
        let view = CourseRatingView(appearance: appearance)
        return view
    }()

    var moreActionAnchorView: UIView { self.moreButton }

    var onCoverClick: (() -> Void)?
    var onMoreClick: (() -> Void)?

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
        self.titleLabel.text = viewModel?.title
        self.textLabel.text = viewModel?.text
        self.dateLabel.text = viewModel?.dateRepresentation
        self.scoreView.starsCount = viewModel?.score ?? 0
        self.coverView.shouldShowAdaptiveMark = viewModel?.shouldShowAdaptiveMark ?? false
    }

    @objc
    private func coverButtonClicked() {
        self.onCoverClick?()
    }

    @objc
    private func moreButtonClicked() {
        self.onMoreClick?()
    }
}

extension UserCoursesReviewsLeavedReviewCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.coverOverlayButton)
        self.addSubview(self.titleLabel)
        self.addSubview(self.moreButton)
        self.addSubview(self.textLabel)
        self.addSubview(self.dateLabel)
        self.addSubview(self.scoreView)
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
            make.trailing.equalTo(self.moreButton.snp.leading).offset(-self.appearance.titleInsets.right)
        }

        self.moreButton.translatesAutoresizingMaskIntoConstraints = false
        self.moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-self.appearance.moreButtonInsets.right)
            make.size.equalTo(self.appearance.moreButtonSize)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.textLabelInsets.top)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.equalTo(self.titleLabel.snp.trailing)
        }

        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.textLabel.snp.bottom).offset(self.appearance.dateLabelInsets.top)
            make.leading.equalTo(self.textLabel.snp.leading)
            make.trailing.equalTo(self.textLabel.snp.trailing)
        }

        self.scoreView.translatesAutoresizingMaskIntoConstraints = false
        self.scoreView.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(self.appearance.scoreInsets.top)
            make.leading.equalTo(self.dateLabel.snp.leading)
            make.bottom.equalToSuperview().offset(-self.appearance.scoreInsets.bottom)
            make.trailing.lessThanOrEqualTo(self.dateLabel.snp.trailing)
        }
    }
}
