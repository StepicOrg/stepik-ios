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

    private lazy var submitButton: UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitleColor(self.appearance.submitButtonTextColor, for: .normal)
        submitButton.titleLabel?.font = self.appearance.submitButtonFont
        submitButton.layer.cornerRadius = self.appearance.submitButtonCornerRadius
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = self.appearance.submitButtonBackgroundColor
        return submitButton
    }()

    private lazy var feedbackView: QuizFeedbackView = {
        let view = QuizFeedbackView(state: .evaluation)
        view.isHidden = true
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.feedbackContainerView, self.submitContainerView])
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var submitContainerView = UIView()
    private lazy var feedbackContainerView = UIView()

    var submitButtonTitle: String? {
        didSet {
            self.submitButton.setTitle(self.submitButtonTitle, for: .normal)
        }
    }

    var isSubmitButtonEnabled = true {
        didSet {
            self.submitButton.isEnabled = self.isSubmitButtonEnabled
        }
    }

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

    func addQuiz(view: UIView) {
        self.stackView.insertArrangedSubview(view, at: 0)
    }

    func updateFeedback(state: QuizFeedbackView.State?, hint: String? = nil) {
        guard let state = state else {
            self.feedbackView.isHidden = true
            return
        }

        self.feedbackView.isHidden = false
        self.feedbackView.update(state: state, hint: hint)
    }
}

extension BaseQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() { }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.submitContainerView.addSubview(self.submitButton)
        self.feedbackContainerView.addSubview(self.feedbackView)
    }

    func makeConstraints() {
        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.submitButtonHeight)
        }

        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.feedbackView.translatesAutoresizingMaskIntoConstraints = false
        self.feedbackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }


        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}
