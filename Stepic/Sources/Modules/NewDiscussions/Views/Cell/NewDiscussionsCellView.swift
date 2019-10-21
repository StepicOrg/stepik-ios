import UIKit

extension NewDiscussionsCellView {
    struct Appearance {
        let avatarImageViewInsets = LayoutInsets(top: 16, left: 16)
        let avatarImageViewSize = CGSize(width: 30, height: 30)
        let avatarImageViewCornerRadius: CGFloat = 4.0

        let nameLabelInsets = LayoutInsets(left: 16, right: 16)
        let nameLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let nameLabelTextColor = UIColor.mainDark

        let textLabelInsets = LayoutInsets(top: 8, right: 16)
        let textLabelFont = UIFont.systemFont(ofSize: 14, weight: .light)
        let textLabelTextColor = UIColor.mainDark

        let bottomControlsSpacing: CGFloat = 4
        let bottomControlsInsets = LayoutInsets(top: 8, left: 16, bottom: 16, right: 16)

        let dateLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let dateLabelTextColor = UIColor.mainDark

        let replyButtonFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let replyButtonTextColor = UIColor(hex: 0x3E50CB)
    }
}

final class NewDiscussionsCellView: UIView {
    let appearance: Appearance

    private lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.shape = .rectangle(cornerRadius: self.appearance.avatarImageViewCornerRadius)
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameLabelFont
        label.textColor = self.appearance.nameLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textLabelFont
        label.textColor = self.appearance.textLabelTextColor
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

    private lazy var replyButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = self.appearance.replyButtonFont
        button.setTitleColor(self.appearance.replyButtonTextColor, for: .normal)
        button.setTitle(NSLocalizedString("Reply", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(self.replyDidClick), for: .touchUpInside)
        return button
    }()

    private lazy var bottomControlsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.dateLabel, self.replyButton])
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.bottomControlsSpacing
        return stackView
    }()

    var onReplyClick: (() -> Void)?

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

    // MARK: - Public API

    func configure(viewModel: NewDiscussionsCommentViewModel?) {
        guard let viewModel = viewModel else {
            self.nameLabel.text = nil
            self.dateLabel.text = nil
            self.textLabel.text = nil
            self.avatarImageView.reset()
            return
        }

        self.nameLabel.text = viewModel.userName
        self.dateLabel.text = viewModel.dateRepresentation
        // TODO: Add LaTeX support via ProcessedContentTextView
        self.textLabel.setTextWithHTMLString(viewModel.text)

        if let url = viewModel.avatarImageURL {
            self.avatarImageView.set(with: url)
        }
    }

    // MARK: - Private API

    @objc
    private func replyDidClick() {
        self.onReplyClick?()
    }
}

// MARK: - NewDiscussionsCellView: ProgrammaticallyInitializableViewProtocol -

extension NewDiscussionsCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.textLabel)
        self.addSubview(self.bottomControlsStackView)
    }

    func makeConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.avatarImageViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.avatarImageViewInsets.top)
            make.size.equalTo(self.appearance.avatarImageViewSize)
        }

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.nameLabelInsets.left)
            make.top.equalTo(self.avatarImageView.snp.top)
            make.trailing.equalToSuperview().offset(-self.appearance.nameLabelInsets.right)
        }

        self.textLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(self.appearance.textLabelInsets.top)
            make.leading.equalTo(self.nameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-self.appearance.textLabelInsets.right)
        }

        self.bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomControlsStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.bottomControlsInsets.left)
            make.top.equalTo(self.textLabel.snp.bottom).offset(self.appearance.bottomControlsInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.bottomControlsInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.bottomControlsInsets.bottom)
        }
    }
}
