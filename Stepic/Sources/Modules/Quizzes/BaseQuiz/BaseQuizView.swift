import SnapKit
import UIKit

protocol BaseQuizViewDelegate: AnyObject {
    func baseQuizViewDidRequestSubmit(_ view: BaseQuizView)
    func baseQuizViewDidRequestNextStep(_ view: BaseQuizView)
    func baseQuizViewDidRequestReviewCreateSession(_ view: BaseQuizView)
    func baseQuizViewDidRequestReviewSolveAgain(_ view: BaseQuizView)
    func baseQuizViewDidRequestReviewSelectDifferentSubmission(_ view: BaseQuizView)
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

        let withInsets = LayoutInsets(left: 16, right: 16)
        let withoutHorizontalInsets = LayoutInsets(inset: 0)
        let withoutHorizontalInsetsChildQuiz = LayoutInsets(top: 0, left: -16, bottom: 0, right: -16)

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

    weak var delegate: BaseQuizViewDelegate?

    let appearance: Appearance
    private let withHorizontalInsets: Bool

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
    private lazy var discountingPolicyContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
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
    private lazy var feedbackContainerView = UIView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var submitControlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.spacing
        return stackView
    }()
    private lazy var submitControlsContainerView = UIView()

    private lazy var reviewControls: QuizReviewControlsView = {
        let view = QuizReviewControlsView()
        view.isHidden = true
        view.onCreateSessionClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.baseQuizViewDidRequestReviewCreateSession(strongSelf)
        }
        view.onSolveAgainClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.baseQuizViewDidRequestReviewSolveAgain(strongSelf)
        }
        view.onSelectDifferentSubmissionClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.baseQuizViewDidRequestReviewSelectDifferentSubmission(strongSelf)
        }
        return view
    }()

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

    var isReviewAvailable = false

    var isReviewControlsAvailable = false {
        didSet {
            let shouldShowReviewControls = self.isReviewAvailable && self.isReviewControlsAvailable
            self.reviewControls.isHidden = !shouldShowReviewControls
            self.submitControlsContainerView.isHidden = shouldShowReviewControls
        }
    }

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

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        withHorizontalInsets: Bool
    ) {
        self.appearance = appearance
        self.withHorizontalInsets = withHorizontalInsets

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

        let stackIndex: Int = {
            guard let discountingPolicyLabelIndex = self.stackView.arrangedSubviews.firstIndex(
                where: { $0 === self.discountingPolicyContainerView }
            ) else {
                return 0
            }
            return discountingPolicyLabelIndex + 1
        }()

        if self.withHorizontalInsets {
            self.stackView.insertArrangedSubview(view, at: stackIndex)
        } else {
            let containerView = UIView()
            self.stackView.insertArrangedSubview(containerView, at: stackIndex)

            containerView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(self.appearance.withoutHorizontalInsetsChildQuiz.edgeInsets)
            }
        }
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
            self.retryButton.isHidden = true
            self.retryButton.isEnabled = true
        } else if self.isNextStepAvailable && !self.isRetryAvailable {
            // Disable retry button when there are no more submissions left.
            self.retryButton.isHidden = false
            self.retryButton.isEnabled = false
        } else {
            self.retryButton.isHidden = !self.isRetryAvailable
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
}

extension BaseQuizView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.separatorView)
        self.stackView.addArrangedSubview(self.discountingPolicyContainerView)
        self.stackView.addArrangedSubview(self.feedbackContainerView)
        self.stackView.addArrangedSubview(self.submitControlsContainerView)
        self.stackView.addArrangedSubview(self.reviewControls)

        self.discountingPolicyContainerView.addSubview(self.discountingPolicyLabel)
        self.submitControlsContainerView.addSubview(self.submitControlsStackView)
        self.feedbackContainerView.addSubview(self.feedbackView)

        self.submitControlsStackView.addArrangedSubview(self.retryButton)
        self.submitControlsStackView.addArrangedSubview(self.submitButton)

        self.addSubview(self.loadingIndicatorView)
    }

    func makeConstraints() {
        let insets = self.withHorizontalInsets
            ? self.appearance.withInsets
            : self.appearance.withoutHorizontalInsets

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.discountingPolicyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.discountingPolicyLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(insets.left)
            make.trailing.equalToSuperview().offset(-insets.right)
        }

        self.submitControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.submitControlsStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(insets.left)
            make.trailing.equalToSuperview().offset(-insets.right)
        }

        self.retryButton.translatesAutoresizingMaskIntoConstraints = false
        self.retryButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.retryButtonSize)
        }

        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.submitButtonHeight)
        }

        self.feedbackView.translatesAutoresizingMaskIntoConstraints = false
        self.feedbackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(insets.left)
            make.trailing.equalToSuperview().offset(-insets.right)
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
