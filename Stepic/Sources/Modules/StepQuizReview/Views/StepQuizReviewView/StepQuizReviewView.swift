import SnapKit
import UIKit

extension StepQuizReviewView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground
        let insets = LayoutInsets.default

        let messageViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)

        let stackViewSpacing: CGFloat = 0
        let stackViewInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
}

final class StepQuizReviewView: UIView, StepQuizReviewViewProtocol {
    weak var delegate: StepQuizReviewViewDelegate?

    let appearance: Appearance

    private lazy var topSeparatorView = SeparatorView()

    private lazy var messageView = StepQuizReviewMessageView()
    private lazy var messageContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private lazy var statusesView = StepQuizReviewStatusesView()

    private lazy var quizContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

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
        self.messageContainerView.isHidden = self.messageView.title?.isEmpty ?? true

        self.quizContainerView.isHidden = true
        self.statusesView.removeAllReviewStatuses()

        if viewModel.isInstructorInstructionType {
            self.configureInstructorReview(viewModel)
        } else {
            self.configurePeerReview(viewModel)
        }

        self.statusesView.makeReviewStatusesJoined()
    }

    private func configureInstructorReview(_ viewModel: StepQuizReviewViewModel) {
        let stage = viewModel.stage ?? .submissionNotMade

        // 1
        let statusView1 = StepQuizReviewStatusView()
        statusView1.position = 1
        statusView1.status = { () -> StepQuizReviewStatusView.Status in
            switch stage {
            case .submissionNotMade:
                return viewModel.isSubmissionWrong ? .error : .inProgress
            case .submissionNotSelected, .submissionSelected, .completed:
                return .completed
            }
        }()
        statusView1.title = viewModel.quizTitle

        let statusContainerView1: StepQuizReviewStatusContainerView = {
            if statusView1.status == .completed {
                return StepQuizReviewStatusContainerView(headerView: statusView1)
            } else {
                self.quizContainerView.isHidden = false
                return StepQuizReviewStatusContainerView(headerView: statusView1, contentView: self.quizContainerView)
            }
        }()
        self.statusesView.addArrangedReviewStatus(statusContainerView1)

        // 2
        let statusView2 = StepQuizReviewStatusView()
        statusView2.position = 2
        statusView2.status = .completed
        statusView2.title = "Решение отправлено на проверку"
        let statusContainerView2 = StepQuizReviewStatusContainerView(headerView: statusView2)
        self.statusesView.addArrangedReviewStatus(statusContainerView2)

        // 3
        let statusView3 = StepQuizReviewStatusView()
        statusView3.position = 3
        statusView3.isLastPosition = true
        statusView3.status = .inProgress
        statusView3.title = "Дождитесь оценки преподавателя. Максимум за задачу — 7 баллов."
        let messageView3 = StepQuizReviewMessageView()
        messageView3.title = "Преподаватель скоро приступит к проверке. Вы можете продолжить обучение."
        let statusContainerView3 = StepQuizReviewStatusContainerView(
            headerView: statusView3,
            contentView: messageView3,
            shouldShowSeparator: true
        )
        self.statusesView.addArrangedReviewStatus(statusContainerView3)
    }

    private func configurePeerReview(_ viewModel: StepQuizReviewViewModel) {}
}

extension StepQuizReviewView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.topSeparatorView)
        self.stackView.addArrangedSubview(self.messageContainerView)
        self.stackView.addArrangedSubview(self.statusesView)

        self.messageContainerView.addSubview(self.messageView)
    }

    func makeConstraints() {
        self.messageView.translatesAutoresizingMaskIntoConstraints = false
        self.messageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.messageViewInsets)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.stackViewInsets)
        }
    }
}

extension StepQuizReviewView {
    private func configureDummyPeerReview() {
        self.messageView.title = """
Проверка задачи способом рецензирования. Выполните следующие шаги для получения баллов за задание.
"""

        let statusView1 = StepQuizReviewStatusView()
        statusView1.position = 1
        statusView1.status = .inProgress
        statusView1.title = "Решите задачу"
        let statusContainerView1 = StepQuizReviewStatusContainerView(headerView: statusView1)
        self.statusesView.addArrangedReviewStatus(statusContainerView1)

        let statusView2 = StepQuizReviewStatusView()
        statusView2.position = 2
        statusView2.status = .pending
        statusView2.title = "Отправьте лучшее из решений на проверку. После отправки заменить решение нельзя."
        let statusContainerView2 = StepQuizReviewStatusContainerView(headerView: statusView2)
        self.statusesView.addArrangedReviewStatus(statusContainerView2)

        let statusView3 = StepQuizReviewStatusView()
        statusView3.position = 3
        statusView3.status = .pending
        statusView3.title = "Сделайте 3 рецензии на решения других учащихся"
        let statusContainerView3 = StepQuizReviewStatusContainerView(headerView: statusView3)
        self.statusesView.addArrangedReviewStatus(statusContainerView3)

        let statusView4 = StepQuizReviewStatusView()
        statusView4.position = 4
        statusView4.status = .pending
        statusView4.title = "Дождитесь 3 рецензии на свое решение"
        let statusContainerView4 = StepQuizReviewStatusContainerView(headerView: statusView4)
        self.statusesView.addArrangedReviewStatus(statusContainerView4)

        let statusView5 = StepQuizReviewStatusView()
        statusView5.position = 5
        statusView5.isLastPosition = true
        statusView5.status = .pending
        statusView5.title = "Получите баллы. Максимум за задачу — 7 баллов."
        let statusContainerView5 = StepQuizReviewStatusContainerView(headerView: statusView5)
        self.statusesView.addArrangedReviewStatus(statusContainerView5)

        self.statusesView.makeReviewStatusesJoined()
    }

    private func configureDummyInstructorReview() {
        let statusView1 = StepQuizReviewStatusView()
        statusView1.position = 1
        statusView1.status = .completed
        statusView1.title = "Решите задачу"
        let statusContainerView1 = StepQuizReviewStatusContainerView(headerView: statusView1)
        self.statusesView.addArrangedReviewStatus(statusContainerView1)

        let statusView2 = StepQuizReviewStatusView()
        statusView2.position = 2
        statusView2.status = .completed
        statusView2.title = "Решение отправлено на проверку"
        let statusContainerView2 = StepQuizReviewStatusContainerView(headerView: statusView2)
        self.statusesView.addArrangedReviewStatus(statusContainerView2)

        let statusView3 = StepQuizReviewStatusView()
        statusView3.position = 3
        statusView3.isLastPosition = true
        statusView3.status = .inProgress
        statusView3.title = "Дождитесь оценки преподавателя. Максимум за задачу — 7 баллов."
        let messageView3 = StepQuizReviewMessageView()
        messageView3.title = "Преподаватель скоро приступит к проверке. Вы можете продолжить обучение."
        let statusContainerView3 = StepQuizReviewStatusContainerView(
            headerView: statusView3,
            contentView: messageView3,
            shouldShowSeparator: true
        )
        self.statusesView.addArrangedReviewStatus(statusContainerView3)

        self.statusesView.makeReviewStatusesJoined()
    }
}
