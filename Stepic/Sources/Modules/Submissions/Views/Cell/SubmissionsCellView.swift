import SnapKit
import UIKit

extension SubmissionsCellView {
    struct Appearance {
        let avatarImageViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 0)
        let avatarImageViewSize = CGSize(width: 36, height: 36)
        let avatarImageViewCornerRadius: CGFloat = 4.0

        let nameLabelTextColor = UIColor.stepikAccent
        let nameLabelFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let nameLabelInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let solutionControlHeight = DiscussionsSolutionControl.Appearance.height
        let solutionControlInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)

        let dateLabelInsets = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        let dateLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let dateLabelTextColor = UIColor.stepikAccent
    }
}

final class SubmissionsCellView: UIView {
    let appearance: Appearance

    private lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.shape = .rectangle(cornerRadius: self.appearance.avatarImageViewCornerRadius)
        return view
    }()

    private lazy var avatarOverlayButton: UIButton = {
        let button = HighlightFakeButton()
        button.highlightedBackgroundColor = UIColor.white.withAlphaComponent(0.5)
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

    private lazy var solutionControl: DiscussionsSolutionControl = {
        let control = DiscussionsSolutionControl()
        control.addTarget(self, action: #selector(self.solutionControlClicked), for: .touchUpInside)
        return control
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    var onAvatarClick: (() -> Void)?
    var onSolutionClick: (() -> Void)?

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

    func configure(viewModel: SubmissionsViewModel?) {
        guard let viewModel = viewModel else {
            self.nameLabel.text = nil
            self.dateLabel.text = nil
            self.solutionControl.update(state: .wrong, title: nil)
            self.avatarImageView.reset()
            return
        }

        self.nameLabel.text = viewModel.formattedUsername
        self.dateLabel.text = viewModel.formattedDate

        self.solutionControl.update(
            state: viewModel.isSubmissionCorrect ? .correct : .wrong,
            title: viewModel.submissionTitle
        )

        if let url = viewModel.avatarImageURL {
            self.avatarImageView.set(with: url)
        }
    }

    @objc
    private func avatarButtonClicked() {
        self.onAvatarClick?()
    }

    @objc
    private func solutionControlClicked() {
        self.onSolutionClick?()
    }
}

extension SubmissionsCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.avatarOverlayButton)
        self.addSubview(self.nameLabel)
        self.addSubview(self.solutionControl)
        self.addSubview(self.dateLabel)
    }

    func makeConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.avatarImageViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.avatarImageViewInsets.top)
            make.size.equalTo(self.appearance.avatarImageViewSize)
        }

        self.avatarOverlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.avatarOverlayButton.snp.makeConstraints { make in
            make.edges.equalTo(self.avatarImageView)
        }

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.avatarImageView.snp.top)
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.nameLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.nameLabelInsets.right)
        }

        self.solutionControl.translatesAutoresizingMaskIntoConstraints = false
        self.solutionControl.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.solutionControlHeight)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(self.appearance.solutionControlInsets.top)
            make.leading.equalTo(self.nameLabel.snp.leading)
            make.trailing.equalTo(self.nameLabel.snp.trailing)
        }

        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.solutionControl.snp.bottom).offset(self.appearance.dateLabelInsets.top)
            make.leading.equalTo(self.solutionControl.snp.leading)
            make.bottom.equalToSuperview().offset(-self.appearance.dateLabelInsets.bottom)
            make.trailing.equalTo(self.solutionControl.snp.trailing)
        }
    }
}
