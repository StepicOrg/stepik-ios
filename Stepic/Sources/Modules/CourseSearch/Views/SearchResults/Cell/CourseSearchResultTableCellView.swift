import SnapKit
import UIKit

extension CourseSearchResultTableCellView {
    struct Appearance {
        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets.default

        let coverImageViewCornerRadius: CGFloat = 6
        let coverImageViewInsets = LayoutInsets.default
        let coverImageViewSize = CGSize(width: 32, height: 32)

        let titleTextColor = UIColor.stepikMaterialPrimaryText
        let titleFont = Typography.subheadlineFont
        let titleLabelInsets = LayoutInsets.default
    }
}

final class CourseSearchResultTableCellView: UIView {
    let appearance: Appearance

    private lazy var coverImageView: CourseCoverImageView = {
        let view = CourseCoverImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.coverImageViewCornerRadius
        return view
    }()

    private lazy var coverOverlayButton: UIButton = {
        let button = HighlightFakeButton()
        button.highlightedBackgroundColor = UIColor.stepikTertiaryBackground.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(self.coverButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var statsView = CourseInfoTabSyllabusCellStatsView()

    private lazy var statsContainerView = UIView()

    private lazy var commentView: CourseSearchResultCommentView = {
        let view = CourseSearchResultCommentView()
        view.addTarget(self, action: #selector(self.commentViewClicked), for: .touchUpInside)
        view.isHidden = true
        return view
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    var onCoverClick: (() -> Void)?

    var onCommentClick: (() -> Void)?

    var onCommentUserAvatarClick: (() -> Void)? {
        get {
            self.commentView.onAvatarClick
        }
        set {
            self.commentView.onAvatarClick = newValue
        }
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

    func configure(viewModel: CourseSearchResultViewModel?) {
        self.coverImageView.loadImage(url: viewModel?.coverImageURL)
        self.titleLabel.text = viewModel?.title

        self.statsView.progressLabelText = viewModel?.progressLabelText
        self.statsView.learnersLabelText = viewModel?.learnersLabelText
        self.statsView.timeToCompleteLabelText = viewModel?.timeToCompleteLabelText
        self.statsView.likesCount = viewModel?.likesCount
        self.statsContainerView.isHidden = self.statsView.isEmpty

        self.commentView.avatarImageURL = viewModel?.comment?.avatarImageURL
        self.commentView.username = viewModel?.comment?.username
        self.commentView.text = viewModel?.comment?.text
        self.commentView.isHidden = viewModel?.comment == nil
    }

    @objc
    private func coverButtonClicked() {
        self.onCoverClick?()
    }

    @objc
    private func commentViewClicked() {
        self.onCommentClick?()
    }
}

extension CourseSearchResultTableCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.containerStackView)
        self.addSubview(self.coverOverlayButton)

        let coverAndTitleStackView = UIStackView(arrangedSubviews: [self.coverImageView, self.titleLabel])
        coverAndTitleStackView.axis = .horizontal
        coverAndTitleStackView.alignment = .top
        coverAndTitleStackView.spacing = self.appearance.stackViewSpacing
        self.containerStackView.addArrangedSubview(coverAndTitleStackView)

        self.statsContainerView.addSubview(self.statsView)
        self.containerStackView.addArrangedSubview(self.statsContainerView)

        self.containerStackView.addArrangedSubview(self.commentView)
    }

    func makeConstraints() {
        self.containerStackView.translatesAutoresizingMaskIntoConstraints = false
        self.containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.stackViewInsets.edgeInsets)
        }

        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.coverImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.coverImageView.snp.makeConstraints { $0.size.equalTo(self.appearance.coverImageViewSize) }

        self.coverOverlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.coverOverlayButton.snp.makeConstraints { $0.edges.equalTo(self.coverImageView) }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        self.statsView.translatesAutoresizingMaskIntoConstraints = false
        self.statsView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.statsView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading
                .equalToSuperview()
                .offset(self.appearance.coverImageViewSize.width + self.appearance.stackViewSpacing)
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
}
