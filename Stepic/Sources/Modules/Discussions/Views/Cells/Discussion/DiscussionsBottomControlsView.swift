import SnapKit
import UIKit

extension DiscussionsBottomControlsView {
    struct Appearance {
        let dateLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let dateLabelTextColor = UIColor.stepikPrimaryText

        let replyButtonFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let replyButtonTextColor = UIColor.stepikDarkVioletFixed

        let spacing: CGFloat = 16
        let subgroupSpacing: CGFloat = 8
    }
}

final class DiscussionsBottomControlsView: UIView {
    let appearance: Appearance

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var replyButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = self.appearance.replyButtonFont
        button.setTitleColor(self.appearance.replyButtonTextColor, for: .normal)
        button.setTitle(NSLocalizedString("Reply", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(self.replyButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var dateAndReplyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = self.appearance.subgroupSpacing
        stackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return stackView
    }()

    private lazy var votesView = DiscussionsVotesView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    var onReplyClick: (() -> Void)?

    var onLikeClick: (() -> Void)? {
        get {
            self.votesView.onLikeClick
        }
        set {
            self.votesView.onLikeClick = newValue
        }
    }

    var onDislikeClick: (() -> Void)? {
        get {
            self.votesView.onDislikeClick
        }
        set {
            self.votesView.onDislikeClick = newValue
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

    func configure(_ viewModel: ViewModel) {
        self.dateLabel.text = viewModel.formattedDateText

        self.votesView.likesCount = viewModel.likesCount
        self.votesView.dislikesCount = viewModel.dislikesCount

        if let voteValue = viewModel.voteValue {
            switch voteValue {
            case .epic:
                self.votesView.state = .liked
            case .abuse:
                self.votesView.state = .disliked
            }
        } else if viewModel.canVote {
            self.votesView.state = .normal
        } else {
            self.votesView.state = .disabled
        }

        self.votesView.isEnabled = viewModel.canVote
    }

    @objc
    private func replyButtonClicked() {
        self.onReplyClick?()
    }

    struct ViewModel {
        let formattedDateText: String?
        let likesCount: Int
        let dislikesCount: Int
        let canVote: Bool
        let voteValue: VoteValue?
    }
}

extension DiscussionsBottomControlsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.dateAndReplyStackView)
        self.stackView.addArrangedSubview(self.votesView)

        self.dateAndReplyStackView.addArrangedSubview(self.dateLabel)
        self.dateAndReplyStackView.addArrangedSubview(self.replyButton)
    }

    func makeConstraints() {
        self.stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
