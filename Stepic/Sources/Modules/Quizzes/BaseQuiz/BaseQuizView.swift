import SnapKit
import UIKit

protocol BaseQuizViewDelegate: AnyObject {
    func baseQuizViewDidRequestSubmit(_ view: BaseQuizView)
    func baseQuizViewDidRequestNextStep(_ view: BaseQuizView)
    func baseQuizViewDidRequestPeerReview(_ view: BaseQuizView)
    func baseQuizView(_ view: BaseQuizView, didRequestFullscreenImage url: URL)
    func baseQuizView(_ view: BaseQuizView, didRequestOpenURL url: URL)
}

extension BaseQuizView {
    struct Appearance {
        let submitButtonHeight: CGFloat = 44

        let retryButtonSize = CGSize(width: 44, height: 44)
        let retryButtonIconSize = CGSize(width: 22, height: 22)
        let retryButtonIconInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 0)
        let retryButtonBorderWidth: CGFloat = 1
        let retryButtonCornerRadius: CGFloat = 6
        let retryButtonBackgroundColor = UIColor.stepikBackground
        let retryButtonTintColor = UIColor.dynamic(light: .stepikSeparator, dark: .stepikOpaqueSeparator)

        let discountingPolicyTextColor = UIColor.stepikPrimaryText
        let discountingPolicyFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let spacing: CGFloat = 16

        let insets = LayoutInsets(left: 16, right: 16)
        let loadingIndicatorColor = UIColor.stepikLoadingIndicator

        let separatorColor = UIColor.stepikSeparator
        let separatorHeight: CGFloat = 0.5
    }

    enum Animation {
        static let appearanceAnimationDuration: TimeInterval = 0.2
        static let appearanceAnimationDelay: TimeInterval = 0.25
    }
}

final class BaseQuizView: UIView {
    private static let childQuizViewTag = 1

    let appearance: Appearance
    weak var delegate: BaseQuizViewDelegate?

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikWhite)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    private lazy var discountingPolicyLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.discountingPolicyTextColor
        label.font = self.appearance.discountingPolicyFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var submitButton: NextStepButton = {
        let button = NextStepButton()
        button.setTitle(nil, for: .normal)
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

    private lazy var feedbackView: QuizFeedbackView = {
        let view = QuizFeedbackView()
        view.isHidden = true
        view.delegate = self
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var submitControlsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.retryContainerView, self.submitContainerView])
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var submitControlsContainerView = UIView()
    private lazy var submitContainerView = UIView()
    private lazy var retryContainerView = UIView()
    private lazy var feedbackContainerView = UIView()
    private lazy var discountingPolicyContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

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
            self.submitButton.alpha = self.isSubmitButtonEnabled ? 1.0 : 0.5
        }
    }

    var isRetryAvailable = false {
        didSet {
            self.updateRetryButton()
            self.updateSubmitButtonStyle()
        }
    }

    var isNextStepAvailable = false {
        didSet {
            if self.isNextStepAvailable {
                self.submitButton.setTitle(NSLocalizedString("NextStepNavigationTitle", comment: ""), for: .normal)
                self.isSubmitButtonEnabled = true
            }
        }
    }

    var isDiscountPolicyAvailable = false {
        didSet {
            self.discountingPolicyContainerView.isHidden = !self.isDiscountPolicyAvailable
        }
    }

    var discountPolicyTitle: String? {
        didSet {
            self.discountingPolicyLabel.text = self.discountPolicyTitle
        }
    }

    var isPeerReviewAvailable = false

    var isTopSeparatorHidden: Bool {
        get {
            self.separatorView.isHidden
        }
        set {
            self.separatorView.isHidden = newValue
        }
    }

    var childQuizView: UIView? {
        self.stackView.arrangedSubviews.first(where: { $0.tag == Self.childQuizViewTag })
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.retryButton.layer.borderColor = self.appearance.retryButtonTintColor.cgColor
    }

    func addQuiz(view: UIView) {
        view.tag = Self.childQuizViewTag

        guard let discountingPolicyLabelIndex = self.stackView.arrangedSubviews.firstIndex(
            where: { $0 === self.discountingPolicyContainerView }
        ) else {
            return self.stackView.insertArrangedSubview(view, at: 0)
        }

        self.stackView.insertArrangedSubview(view, at: discountingPolicyLabelIndex + 1)
    }

    func showFeedback(state: QuizFeedbackView.State, title: String, hint: String? = nil) {
        self.feedbackView.update(state: state, title: title, hint: hint)
        self.feedbackView.isHidden = false
    }

    func hideFeedback() {
        self.feedbackView.isHidden = true
        self.feedbackView.update(state: .evaluation, title: "")
    }

    func startLoading() {
        self.stackView.alpha = 0.0
        self.loadingIndicatorView.startAnimating()
    }

    func endLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.appearanceAnimationDelay) {
            self.loadingIndicatorView.stopAnimating()

            UIView.animate(
                withDuration: Animation.appearanceAnimationDuration,
                animations: {
                    self.stackView.alpha = 1.0
                }
            )
        }
    }

    // MARK: - Private API

    private func updateRetryButton() {
        // Hide retry button for last step in lesson.
        if !self.isNextStepAvailable && self.isRetryAvailable {
            self.retryContainerView.isHidden = true
            self.retryButton.isEnabled = true
        } else if self.isNextStepAvailable && !self.isRetryAvailable {
            // Disable retry button when there are no more submissions left.
            self.retryContainerView.isHidden = false
            self.retryButton.isEnabled = false
        } else {
            self.retryContainerView.isHidden = !self.isRetryAvailable
            self.retryButton.isEnabled = true
        }
    }

    private func updateSubmitButtonStyle() {
        self.submitButton.style = !self.isNextStepAvailable && self.isRetryAvailable ? .outlineDark : .filled
    }

    @objc
    private func submitClicked() {
        if self.isNextStepAvailable {
            self.delegate?.baseQuizViewDidRequestNextStep(self)
        } else {
            self.delegate?.baseQuizViewDidRequestSubmit(self)
        }
    }

    @objc
    private func retryClicked() {
        self.delegate?.baseQuizViewDidRequestSubmit(self)
    }

    @objc
    private func peerReviewSelected() {
        if self.isPeerReviewAvailable {
            self.delegate?.baseQuizViewDidRequestPeerReview(self)
        }
    }
}

extension BaseQuizView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.separatorView)
        self.stackView.addArrangedSubview(self.discountingPolicyContainerView)
        self.stackView.addArrangedSubview(self.feedbackContainerView)
        self.stackView.addArrangedSubview(self.submitControlsContainerView)

        self.discountingPolicyContainerView.addSubview(self.discountingPolicyLabel)
        self.submitControlsContainerView.addSubview(self.submitControlsStackView)
        self.retryContainerView.addSubview(self.retryButton)
        self.submitContainerView.addSubview(self.submitButton)
        self.feedbackContainerView.addSubview(self.feedbackView)

        self.feedbackView.addGestureRecognizer(self.peerReviewTapGestureRecognizer)

        self.addSubview(self.loadingIndicatorView)
    }

    func makeConstraints() {
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.discountingPolicyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.discountingPolicyLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.submitControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.submitControlsStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.retryButton.translatesAutoresizingMaskIntoConstraints = false
        self.retryButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(self.appearance.retryButtonSize)
        }

        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(self.appearance.submitButtonHeight)
        }

        self.feedbackView.translatesAutoresizingMaskIntoConstraints = false
        self.feedbackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension BaseQuizView: QuizFeedbackViewDelegate {
    func quizFeedbackView(_ view: QuizFeedbackView, didRequestFullscreenImage url: URL) {
        self.delegate?.baseQuizView(self, didRequestFullscreenImage: url)
    }

    func quizFeedbackView(_ view: QuizFeedbackView, didRequestOpenURL url: URL) {
        self.delegate?.baseQuizView(self, didRequestOpenURL: url)
    }
}
