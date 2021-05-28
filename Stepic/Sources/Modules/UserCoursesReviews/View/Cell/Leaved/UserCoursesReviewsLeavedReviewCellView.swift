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

        let moreButtonTintColor = UIColor.stepikMaterialSecondaryText

        let textLabelFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let textLabelTextColor = UIColor.stepikMaterialSecondaryText

        let dateLabelFont = Typography.caption1Font
        let dateLabelTextColor = UIColor.stepikMaterialSecondaryText

        let scoreClearStarsColor = UIColor.onSurface.withAlphaComponent(0.12)
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

    var coverImageURL: URL? {
        didSet {
            self.coverView.coverImageURL = self.coverImageURL
        }
    }

    var shouldShowAdaptiveMark = false {
        didSet {
            self.coverView.shouldShowAdaptiveMark = self.shouldShowAdaptiveMark
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    var dateText: String? {
        didSet {
            self.dateLabel.text = self.dateText
        }
    }

    var score: Int = 0 {
        didSet {
            self.scoreView.starsCount = self.score
        }
    }

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

    func makeConstraints() {}
}
