import SnapKit
import UIKit

extension NewProfileHeaderView {
    struct Appearance {
        let avatarImageViewSize = CGSize(width: 64, height: 64)
        let avatarImageViewInsets = LayoutInsets(top: 16, left: 16)
        let avatarImageViewBorderWidth: CGFloat = 0.5
        let avatarImageViewBorderColor = UIColor.stepikSeparator

        let usernameLabelTextColor = UIColor.stepikSystemPrimaryText
        let usernameLabelFont = UIFont.systemFont(ofSize: 20, weight: .bold)

        let shortBioLabelTextColor = UIColor.stepikSystemSecondaryText
        let shortBioLabelFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let infoStackViewSpacing: CGFloat = 8
        let infoStackViewInsets = LayoutInsets(left: 16, bottom: 16, right: 16)

        let backgroundColor = UIColor.stepikSecondaryGroupedBackground
    }
}

final class NewProfileHeaderView: UIView {
    let appearance: Appearance

    private lazy var avatarImageView: AvatarImageView = {
        let avatarImageView = AvatarImageView()
        avatarImageView.shape = .circle(
            borderWidth: self.appearance.avatarImageViewBorderWidth,
            borderColor: self.appearance.avatarImageViewBorderColor
        )
        return avatarImageView
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.usernameLabelTextColor
        label.font = self.appearance.usernameLabelFont
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()

    private lazy var shortBioLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.shortBioLabelTextColor
        label.font = self.appearance.shortBioLabelFont
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()

    private lazy var reputationRatingView = NewProfileRatingView(kind: .reputation)
    private lazy var knowledgeRatingView = NewProfileRatingView(kind: .knowledge)

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = self.appearance.infoStackViewSpacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let infoStackViewIntrinsicContentSize = self.infoStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let contentHeight = max(infoStackViewIntrinsicContentSize.height, self.appearance.avatarImageViewSize.height)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.avatarImageViewInsets.top
                + contentHeight
                + self.appearance.infoStackViewInsets.bottom
        )
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

    func configure(viewModel: NewProfileHeaderViewModel) {
        if let avatarURL = viewModel.avatarURL {
            self.avatarImageView.set(with: avatarURL)
        } else {
            self.avatarImageView.reset()
        }

        self.usernameLabel.text = viewModel.username

        self.shortBioLabel.text = viewModel.shortBio
        self.shortBioLabel.isHidden = viewModel.shortBio.isEmpty

        if let reputationCount = viewModel.reputationCount {
            self.reputationRatingView.number = reputationCount
            self.reputationRatingView.isHidden = false
        } else {
            self.reputationRatingView.number = nil
            self.reputationRatingView.isHidden = true
        }

        if let knowledgeCount = viewModel.knowledgeCount {
            self.knowledgeRatingView.number = knowledgeCount
            self.knowledgeRatingView.isHidden = false
        } else {
            self.knowledgeRatingView.number = nil
            self.knowledgeRatingView.isHidden = true
        }
    }
}

extension NewProfileHeaderView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.avatarImageView.reset()
    }

    func addSubviews() {
        self.addSubview(self.avatarImageView)

        self.addSubview(self.infoStackView)
        self.infoStackView.addArrangedSubview(self.usernameLabel)
        self.infoStackView.addArrangedSubview(self.shortBioLabel)
        self.infoStackView.addArrangedSubview(self.reputationRatingView)
        self.infoStackView.addArrangedSubview(self.knowledgeRatingView)
    }

    func makeConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.avatarImageViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.avatarImageViewInsets.left)
            make.width.equalTo(self.appearance.avatarImageViewSize.width)
            make.height.equalTo(self.appearance.avatarImageViewSize.height)
        }

        self.infoStackView.translatesAutoresizingMaskIntoConstraints = false
        self.infoStackView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarImageView.snp.top)
            make.leading
                .equalTo(self.avatarImageView.snp.trailing)
                .offset(self.appearance.infoStackViewInsets.left)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.infoStackViewInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.infoStackViewInsets.right)
        }
    }
}
