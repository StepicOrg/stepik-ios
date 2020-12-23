import SnapKit
import UIKit

protocol SolutionViewDelegate: AnyObject {
    func solutionView(_ view: SolutionView, didRequestOpenURL url: URL)
    func solutionViewDidClickAction(_ view: SolutionView)
}

extension SolutionView {
    struct Appearance {
        let insets = LayoutInsets(left: 16, right: 16)
        let spacing: CGFloat = 16

        let loadingIndicatorColor = UIColor.stepikLoadingIndicator

        let actionButtonBackgroundColor = UIColor.dynamic(light: .stepikGreen, dark: .stepikDarkGreenFixed)
        let actionButtonHeight: CGFloat = 44
        let actionButtonTextColor = UIColor.white
        let actionButtonCornerRadius: CGFloat = 6
        let actionButtonFont = UIFont.systemFont(ofSize: 16)
    }

    enum Animation {
        static let appearanceAnimationDuration: TimeInterval = 0.25
        static let appearanceAnimationDelay: TimeInterval = 0.3
    }
}

final class SolutionView: UIView {
    let appearance: Appearance
    weak var delegate: SolutionViewDelegate?

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikWhite)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView(orientation: .vertical)
        view.spacing = self.appearance.spacing
        view.contentInsets = .init(top: self.appearance.spacing, left: 0, bottom: 0, right: 0)

        if #available(iOS 13.0, *) {
            view.automaticallyAdjustsScrollIndicatorInsets = false
        }

        return view
    }()

    private lazy var feedbackView: QuizFeedbackView = {
        let view = QuizFeedbackView()
        view.isHidden = true
        view.delegate = self
        return view
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(self.appearance.actionButtonTextColor, for: .normal)
        button.titleLabel?.font = self.appearance.actionButtonFont
        button.layer.cornerRadius = self.appearance.actionButtonCornerRadius
        button.clipsToBounds = true
        button.backgroundColor = self.appearance.actionButtonBackgroundColor
        button.addTarget(self, action: #selector(self.actionClicked), for: .touchUpInside)
        return button
    }()

    private lazy var quizContainerView = UIView()
    private lazy var feedbackContainerView = UIView()
    private lazy var actionContainerView = UIView()

    var actionTitle: String? {
        didSet {
            self.actionButton.setTitle(self.actionTitle, for: .normal)
        }
    }

    var actionIsHidden = true {
        didSet {
            self.actionContainerView.isHidden = self.actionIsHidden
        }
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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

    // MARK: Public API

    func addQuiz(view: UIView) {
        self.quizContainerView.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        self.scrollableStackView.alpha = 0.0
        self.loadingIndicatorView.startAnimating()
    }

    func endLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.appearanceAnimationDelay) {
            self.loadingIndicatorView.stopAnimating()

            UIView.animate(
                withDuration: Animation.appearanceAnimationDuration,
                animations: {
                    self.scrollableStackView.alpha = 1.0
                }
            )
        }
    }

    // MARK: Private API

    @objc
    private func actionClicked() {
        self.delegate?.solutionViewDidClickAction(self)
    }
}

extension SolutionView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .stepikBackground
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)

        self.scrollableStackView.addArrangedView(self.quizContainerView)
        self.scrollableStackView.addArrangedView(self.feedbackContainerView)
        self.scrollableStackView.addArrangedView(self.actionContainerView)

        self.feedbackContainerView.addSubview(self.feedbackView)
        self.actionContainerView.addSubview(self.actionButton)

        self.addSubview(self.loadingIndicatorView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.feedbackView.translatesAutoresizingMaskIntoConstraints = false
        self.feedbackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.height.equalTo(self.appearance.actionButtonHeight)
        }

        self.loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension SolutionView: QuizFeedbackViewDelegate {
    func quizFeedbackView(_ view: QuizFeedbackView, didRequestFullscreenImage url: URL) {}

    func quizFeedbackView(_ view: QuizFeedbackView, didRequestOpenURL url: URL) {
        self.delegate?.solutionView(self, didRequestOpenURL: url)
    }
}
