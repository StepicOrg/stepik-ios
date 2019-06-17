import SnapKit
import UIKit

extension BaseQuizView {
    struct Appearance {
        let submitButtonBackgroundColor = UIColor.stepicGreen
        let submitButtonHeight: CGFloat = 44
        let submitButtonTextColor = UIColor.white
        let submitButtonCornerRadius: CGFloat = 6
        let submitButtonFont = UIFont.systemFont(ofSize: 16)

        let spacing: CGFloat = 16

        let insets = LayoutInsets(left: 16, right: 16)
    }
}

final class BaseQuizView: UIView {
    let appearance: Appearance

    lazy var submitButton: UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitleColor(self.appearance.submitButtonTextColor, for: .normal)
        submitButton.titleLabel?.font = self.appearance.submitButtonFont
        submitButton.setTitle("Отправить", for: .normal)
        submitButton.layer.cornerRadius = self.appearance.submitButtonCornerRadius
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = self.appearance.submitButtonBackgroundColor
        return submitButton
    }()

    lazy var feedbackView: QuizFeedbackView = {
        let feedbackView = QuizFeedbackView(state: .evaluation)
        feedbackView.isHidden = true
        return feedbackView
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.feedbackView, self.submitButton])
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

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
}

extension BaseQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() { }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.submitButtonHeight)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }
    }
}
