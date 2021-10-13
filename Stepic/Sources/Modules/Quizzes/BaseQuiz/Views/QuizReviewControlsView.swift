import SnapKit
import UIKit

extension QuizReviewControlsView {
    struct Appearance {
        let submitButtonHeight: CGFloat = 44

        let retryButtonSize = CGSize(width: 44, height: 44)
        let retryButtonIconSize = CGSize(width: 22, height: 22)
        let retryButtonIconInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 0)
        let retryButtonBorderWidth: CGFloat = 1
        let retryButtonCornerRadius: CGFloat = 6
        let retryButtonBackgroundColor = UIColor.stepikBackground
        let retryButtonTintColor = UIColor.stepikGreen

        let spacing: CGFloat = 16
    }
}

final class QuizReviewControlsView: UIView {
    let appearance: Appearance

    private lazy var submitButton: NextStepButton = {
        let button = NextStepButton(style: .filled)
        button.setTitle(NSLocalizedString("StepQuizReviewSendSubmit", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(self.submitClicked), for: .touchUpInside)
        return button
    }()

    private lazy var retryButton: ImageButton = {
        let button = ImageButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = self.appearance.retryButtonCornerRadius
        button.backgroundColor = self.appearance.retryButtonBackgroundColor
        button.layer.borderColor = self.appearance.retryButtonTintColor.cgColor
        button.layer.borderWidth = self.appearance.retryButtonBorderWidth
        button.image = UIImage(named: "Refresh")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = self.appearance.retryButtonTintColor
        button.imageInsets = self.appearance.retryButtonIconInsets
        button.imageSize = self.appearance.retryButtonIconSize
        button.addTarget(self, action: #selector(self.retryClicked), for: .touchUpInside)
        return button
    }()

    private lazy var chooseButton: NextStepButton = {
        let button = NextStepButton(style: .outlineGreen)
        button.setTitle(NSLocalizedString("StepQuizReviewSendChoose", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(self.chooseClicked), for: .touchUpInside)
        return button
    }()

    var onCreateSessionClick: (() -> Void)?
    var onSolveAgainClick: (() -> Void)?
    var onSelectDifferentSubmissionClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.submitButtonHeight * 2 + self.appearance.spacing
        )
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

    @objc
    private func submitClicked() {
        self.onCreateSessionClick?()
    }

    @objc
    private func retryClicked() {
        self.onSolveAgainClick?()
    }

    @objc
    private func chooseClicked() {
        self.onSelectDifferentSubmissionClick?()
    }
}

extension QuizReviewControlsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.submitButton)
        self.addSubview(self.retryButton)
        self.addSubview(self.chooseButton)
    }

    func makeConstraints() {
        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.submitButtonHeight)
        }

        self.retryButton.translatesAutoresizingMaskIntoConstraints = false
        self.retryButton.snp.makeConstraints { make in
            make.top.equalTo(self.submitButton.snp.bottom).offset(self.appearance.spacing)
            make.leading.bottom.equalToSuperview()
            make.size.equalTo(self.appearance.retryButtonSize)
        }

        self.chooseButton.translatesAutoresizingMaskIntoConstraints = false
        self.chooseButton.snp.makeConstraints { make in
            make.top.equalTo(self.submitButton.snp.bottom).offset(self.appearance.spacing)
            make.leading.equalTo(self.retryButton.snp.trailing).offset(self.appearance.spacing)
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.submitButtonHeight)
        }
    }
}
