import SnapKit
import UIKit

protocol BaseQuizViewDelegate: class {
    func baseQuizViewDidRequestSubmit(_ view: BaseQuizView)
    func baseQuizViewDidRequestPeerReview(_ view: BaseQuizView)
}

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
    weak var delegate: BaseQuizViewDelegate?

    private lazy var submitButton: UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitleColor(self.appearance.submitButtonTextColor, for: .normal)
        submitButton.titleLabel?.font = self.appearance.submitButtonFont
        submitButton.layer.cornerRadius = self.appearance.submitButtonCornerRadius
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = self.appearance.submitButtonBackgroundColor
        submitButton.addTarget(self, action: #selector(self.submitClicked), for: .touchUpInside)
        return submitButton
    }()

    private lazy var feedbackView: QuizFeedbackView = {
        let view = QuizFeedbackView()
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

    // Peer review: make feedback view clickable
    private lazy var peerReviewTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(self.peerReviewSelected)
    )

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

    var isPeerReviewAvailable = false {
        didSet {
            self.feedbackView.isUserInteractionEnabled = self.isPeerReviewAvailable
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

    func showFeedback(state: QuizFeedbackView.State, title: String, hint: String? = nil) {
        self.feedbackView.update(state: state, title: title, hint: hint)
        self.feedbackView.isHidden = false
    }

    func hideFeedback() {
        self.feedbackView.isHidden = true
        self.feedbackView.update(state: .evaluation, title: "")
    }

    // MARK: - Private API

    @objc
    private func submitClicked() {
        self.delegate?.baseQuizViewDidRequestSubmit(self)
    }

    @objc
    private func peerReviewSelected() {
        self.delegate?.baseQuizViewDidRequestPeerReview(self)
    }
}

extension BaseQuizView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)

        self.submitContainerView.addSubview(self.submitButton)
        self.feedbackContainerView.addSubview(self.feedbackView)

        self.feedbackView.addGestureRecognizer(self.peerReviewTapGestureRecognizer)
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
