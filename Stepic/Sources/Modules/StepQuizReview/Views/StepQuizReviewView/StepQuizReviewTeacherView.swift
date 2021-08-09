import SnapKit
import UIKit

extension StepQuizReviewTeacherView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let messageViewInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let actionButtonMinHeight: CGFloat = 44
        let actionButtonInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
}

final class StepQuizReviewTeacherView: UIView, StepQuizReviewViewProtocol {
    weak var delegate: StepQuizReviewViewDelegate?

    let appearance: Appearance
    private var storedViewModel: StepQuizReviewViewModel?

    private lazy var quizContainerView = UIView()

    private lazy var quizSeparatorView = SeparatorView()

    private lazy var messageView = StepQuizReviewMessageView()
    private lazy var messageContainerView = UIView()

    private lazy var actionButton: UIButton = {
        let button = LessonPanModalActionButton()
        button.addTarget(self, action: #selector(self.actionButtonClicked), for: .touchUpInside)
        return button
    }()
    private lazy var actionButtonContainerView = UIView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: UIView.noIntrinsicMetric, height: stackViewIntrinsicContentSize.height)
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

    func showLoading() {
        self.stackView.alpha = 0
        self.skeleton.viewBuilder = { StepQuizReviewSkeletonView() }
        self.skeleton.show()
    }

    func hideLoading() {
        self.skeleton.hide()
        self.stackView.alpha = 1
    }

    func addQuiz(view: UIView) {
        self.quizContainerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(viewModel: StepQuizReviewViewModel) {
        self.messageView.title = viewModel.infoMessage

        self.actionButton.setTitle(viewModel.primaryActionButtonDescription.title, for: .normal)
        self.actionButton.isEnabled = viewModel.primaryActionButtonDescription.isEnabled
        self.actionButton.alpha = self.actionButton.isEnabled ? 1.0 : 0.5

        self.storedViewModel = viewModel
    }

    @objc
    private func actionButtonClicked() {
        self.delegate?.stepQuizReviewViewView(
            self,
            didClickButtonWith: self.storedViewModel?.primaryActionButtonDescription.uniqueIdentifier
        )
    }
}

extension StepQuizReviewTeacherView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.quizContainerView)
        self.stackView.addArrangedSubview(self.quizSeparatorView)
        self.stackView.addArrangedSubview(self.messageContainerView)
        self.stackView.addArrangedSubview(self.actionButtonContainerView)

        self.messageContainerView.addSubview(self.messageView)
        self.actionButtonContainerView.addSubview(self.actionButton)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.stackViewInsets)
        }

        self.messageView.translatesAutoresizingMaskIntoConstraints = false
        self.messageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.messageViewInsets)
        }

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.actionButtonInsets)
            make.height.greaterThanOrEqualTo(self.appearance.actionButtonMinHeight)
        }
    }
}
