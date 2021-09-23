import SnapKit
import UIKit

extension SubmissionsCellView {
    struct Appearance {
        let avatarInsets = LayoutInsets(top: 16, left: 16)
        let avatarSize = CGSize(width: 36, height: 36)
        let avatarCornerRadius: CGFloat = 4
        let avatarHighlightedBackgroundColor = UIColor.stepikTertiaryBackground.withAlphaComponent(0.5)

        let nameLabelFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let nameLabelTextColor = UIColor.stepikSystemPrimaryText
        let nameLabelInsets = LayoutInsets(left: 16, right: 16)

        let dateLabelFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let dateLabelTextColor = UIColor.stepikSystemSecondaryText

        let moreButtonSize = CGSize(width: 26, height: 26)
        let moreButtonTintColor = UIColor.stepikSystemSecondaryText
        let moreButtonInsets = LayoutInsets(right: 16)

        let submissionViewInsets = LayoutInsets(top: 16, bottom: 16)
    }
}

final class SubmissionsCellView: UIView {
    let appearance: Appearance

    private lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.shape = .rectangle(cornerRadius: self.appearance.avatarCornerRadius)
        return view
    }()

    private lazy var avatarOverlayButton: UIButton = {
        let button = HighlightFakeButton()
        button.highlightedBackgroundColor = self.appearance.avatarHighlightedBackgroundColor
        button.addTarget(self, action: #selector(self.avatarButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameLabelFont
        label.textColor = self.appearance.nameLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var moreButton: UIButton = {
        let image = UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = self.appearance.moreButtonTintColor
        button.addTarget(self, action: #selector(self.moreButtonClicked), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var submissionView = SubmissionView()

    private lazy var reviewView: SubmissionsReviewView = {
        let view = SubmissionsReviewView()
        view.addTarget(self, action: #selector(self.reviewViewClicked), for: .touchUpInside)
        view.isHidden = true
        return view
    }()

    private lazy var selectSubmissionView: SubmissionsSelectionView = {
        let view = SubmissionsSelectionView()
        view.addTarget(self, action: #selector(self.selectSubmissionClicked), for: .touchUpInside)
        view.isHidden = true
        return view
    }()

    private lazy var bottomControlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    var moreActionAnchorView: UIView { self.moreButton }

    var onAvatarClick: (() -> Void)?
    var onMoreClick: (() -> Void)?
    var onReviewClick: (() -> Void)?
    var onSelectSubmissionClick: (() -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    func configure(viewModel: SubmissionViewModel?) {
        guard let viewModel = viewModel else {
            self.nameLabel.text = nil
            self.dateLabel.text = nil
            self.submissionView.status = .evaluation
            self.submissionView.title = nil
            self.submissionView.score = nil
            self.reviewView.isHidden = true
            self.selectSubmissionView.isHidden = true
            self.moreButton.isHidden = true
            self.avatarImageView.reset()
            return
        }

        self.nameLabel.text = viewModel.formattedUsername
        self.dateLabel.text = viewModel.formattedDate

        self.moreButton.isHidden = !viewModel.isMoreActionAvailable

        self.submissionView.status = viewModel.quizStatus
        self.submissionView.title = viewModel.submissionTitle
        self.submissionView.score = viewModel.score

        if let reviewViewModel = viewModel.review {
            self.reviewView.title = reviewViewModel.title
            self.reviewView.actionTitle = reviewViewModel.actionButtonTitle
            self.reviewView.isEnabled = reviewViewModel.isEnabled
            self.reviewView.isHidden = false
        } else {
            self.reviewView.isHidden = true
        }

        self.selectSubmissionView.isHidden = !viewModel.isSelectionAvailable

        if let url = viewModel.avatarImageURL {
            self.avatarImageView.set(with: url)
        }
    }

    @objc
    private func avatarButtonClicked() {
        self.onAvatarClick?()
    }

    @objc
    private func moreButtonClicked() {
        self.onMoreClick?()
    }

    @objc
    private func reviewViewClicked() {
        self.onReviewClick?()
    }

    @objc
    private func selectSubmissionClicked() {
        self.onSelectSubmissionClick?()
    }
}

extension SubmissionsCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        // FIXME: Embed in vertical stack view
        self.addSubview(self.avatarImageView)
        self.addSubview(self.avatarOverlayButton)
        self.addSubview(self.nameLabel)
        self.addSubview(self.dateLabel)
        self.addSubview(self.moreButton)
        self.addSubview(self.submissionView)
        self.addSubview(self.bottomControlsStackView)

        self.bottomControlsStackView.addArrangedSubview(self.reviewView)
        self.bottomControlsStackView.addArrangedSubview(self.selectSubmissionView)
    }

    func makeConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.avatarInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.avatarInsets.left)
            make.size.equalTo(self.appearance.avatarSize)
        }

        self.avatarOverlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.avatarOverlayButton.snp.makeConstraints { $0.edges.equalTo(self.avatarImageView) }

        self.moreButton.translatesAutoresizingMaskIntoConstraints = false
        self.moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.moreButtonInsets.right)
            make.centerY.equalTo(self.avatarImageView.snp.centerY)
            make.size.equalTo(self.appearance.moreButtonSize)
        }

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.avatarImageView.snp.top)
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.nameLabelInsets.left)
            make.trailing.equalTo(self.moreButton.snp.leading)
        }

        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.nameLabel.snp.leading)
            make.bottom.equalTo(self.avatarImageView.snp.bottom)
            make.trailing.equalTo(self.nameLabel.snp.trailing)
        }

        self.submissionView.translatesAutoresizingMaskIntoConstraints = false
        self.submissionView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(self.appearance.submissionViewInsets.top)
            make.leading.equalTo(self.avatarImageView.snp.leading)
            make.trailing.equalTo(self.moreButton.snp.trailing)
            make.bottom
                .equalTo(self.bottomControlsStackView.snp.top)
                .offset(-self.appearance.submissionViewInsets.bottom)
        }

        self.bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomControlsStackView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}
