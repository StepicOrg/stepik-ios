import SnapKit
import UIKit

extension SubmissionView {
    struct Appearance {
        let statusViewSize = CGSize(width: 10, height: 10)
        let statusViewInsets = LayoutInsets(right: 8)

        let statusLabelFont = Typography.caption1Font
        let statusLabelInsets = LayoutInsets(top: 8)

        let titleLabelFont = Typography.makeMonospacedFont(ofSize: 15, weight: .semibold)
        let titleLabelTextColor = UIColor.stepikSystemSecondaryText

        let scoreTitleFont = Typography.headlineFont
        let scoreTitleInsets = LayoutInsets(left: 8)

        let scoreSubtitleFont = Typography.caption1Font
        let scoreSubtitleInsets = LayoutInsets(top: 8)

        let scoreTextColor = UIColor.stepikVioletFixed
    }
}

final class SubmissionView: UIView {
    let appearance: Appearance

    private lazy var statusView: UIView = {
        let view = UIView()
        view.setRoundedCorners(cornerRadius: self.appearance.statusViewSize.height / 2)
        return view
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.statusLabelFont
        label.numberOfLines = 1
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var scoreTitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.scoreTitleFont
        label.textColor = self.appearance.scoreTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var scoreSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.scoreSubtitleFont
        label.textColor = self.appearance.scoreTextColor
        label.text = NSLocalizedString("SubmissionScoreText", comment: "")
        label.numberOfLines = 1
        return label
    }()

    private var titleLabelTopToSuperview: Constraint?
    private var titleLabelCenterYToScoreTitleCenterY: Constraint?

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var score: String? {
        didSet {
            self.scoreTitleLabel.text = self.score

            let isEmpty = self.score?.isEmpty ?? true
            self.scoreTitleLabel.isHidden = isEmpty
            self.scoreSubtitleLabel.isHidden = isEmpty

            self.updateTitleConstraints()
        }
    }

    var status: QuizStatus = .evaluation {
        didSet {
            self.handleStatusUpdated()
        }
    }

    override var intrinsicContentSize: CGSize {
        let titleHeight = max(
            self.titleLabel.intrinsicContentSize.height,
            self.scoreTitleLabel.intrinsicContentSize.height
        )
        let insets = max(self.appearance.statusLabelInsets.top, self.appearance.scoreSubtitleInsets.top)
        let subtitleHeight = max(
            self.statusLabel.intrinsicContentSize.height,
            self.scoreSubtitleLabel.intrinsicContentSize.height
        )

        let height = titleHeight + insets + subtitleHeight

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
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

    private func handleStatusUpdated() {
        switch self.status {
        case .wrong:
            self.statusView.backgroundColor = .stepikLightRedFixed
            self.statusLabel.text = NSLocalizedString("SubmissionStatusWrongText", comment: "")
        case .correct:
            self.statusView.backgroundColor = .stepikGreen
            self.statusLabel.text = NSLocalizedString("SubmissionStatusCorrectText", comment: "")
        case .partiallyCorrect:
            self.statusView.backgroundColor = .stepikDarkYellow
            self.statusLabel.text = NSLocalizedString("SubmissionStatusPartiallyCorrectText", comment: "")
        case .evaluation:
            self.statusView.backgroundColor = .stepikVioletFixed
            self.statusLabel.text = NSLocalizedString("SubmissionStatusEvaluationText", comment: "")
        }

        self.statusLabel.textColor = self.statusView.backgroundColor
    }

    private func updateTitleConstraints() {
        if self.scoreTitleLabel.isHidden {
            self.titleLabelTopToSuperview?.activate()
            self.titleLabelCenterYToScoreTitleCenterY?.deactivate()
        } else {
            self.titleLabelCenterYToScoreTitleCenterY?.activate()
            self.titleLabelTopToSuperview?.deactivate()
        }
    }
}

extension SubmissionView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.statusView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.scoreTitleLabel)
        self.addSubview(self.statusLabel)
        self.addSubview(self.scoreSubtitleLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            self.titleLabelTopToSuperview = make.top.equalToSuperview().constraint
            self.titleLabelCenterYToScoreTitleCenterY = make.centerY
                .equalTo(self.scoreTitleLabel.snp.centerY).constraint
            self.titleLabelTopToSuperview?.deactivate()
        }

        self.statusView.translatesAutoresizingMaskIntoConstraints = false
        self.statusView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(self.titleLabel.snp.leading).offset(-self.appearance.statusViewInsets.right)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.size.equalTo(self.appearance.statusViewSize)
        }

        self.scoreTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.scoreTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading
                .greaterThanOrEqualTo(self.titleLabel.snp.trailing)
                .offset(self.appearance.scoreTitleInsets.left)
            make.trailing.equalToSuperview()
        }

        self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.titleLabel.snp.bottom).offset(self.appearance.statusLabelInsets.top)
            make.leading.bottom.equalToSuperview()
        }

        self.scoreSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.scoreSubtitleLabel.snp.makeConstraints { make in
            make.top
                .greaterThanOrEqualTo(self.scoreTitleLabel.snp.bottom)
                .offset(self.appearance.scoreSubtitleInsets.top)
            make.bottom.trailing.equalToSuperview()
        }
    }
}
