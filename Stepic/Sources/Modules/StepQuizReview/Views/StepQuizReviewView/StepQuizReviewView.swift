import SnapKit
import UIKit

extension StepQuizReviewView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground
        let insets = LayoutInsets.default
    }
}

final class StepQuizReviewView: UIView, StepQuizReviewViewProtocol {
    weak var delegate: StepQuizReviewViewDelegate?

    let appearance: Appearance

    private lazy var messageView = StepQuizReviewMessageView()

    private lazy var statusesView = StepQuizReviewStatusesView()

    private var isPeerReview = false

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        if self.isPeerReview {
            self.configureDummyPeerReview()
        } else {
            self.configureDummyInstructorReview()
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showLoading() {
        self.skeleton.viewBuilder = { StepQuizReviewSkeletonView() }
        self.skeleton.show()
    }

    func hideLoading() {
        self.skeleton.hide()
    }

    func addQuiz(view: UIView) {}

    func configure(viewModel: StepQuizReviewViewModel) {}

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

extension StepQuizReviewView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        if self.isPeerReview {
            self.addSubview(self.messageView)
        }

        self.addSubview(self.statusesView)
    }

    func makeConstraints() {
        if self.isPeerReview {
            self.messageView.translatesAutoresizingMaskIntoConstraints = false
            self.messageView.snp.makeConstraints { make in
                make.top.equalTo(self.safeAreaLayoutGuide).offset(self.appearance.insets.top)
                make.leading.trailing.equalToSuperview().inset(self.appearance.insets.edgeInsets)
            }
        }

        self.statusesView.translatesAutoresizingMaskIntoConstraints = false
        self.statusesView.snp.makeConstraints { make in
            if self.isPeerReview {
                make.top.equalTo(self.messageView.snp.bottom).offset(self.appearance.insets.top)
            } else {
                make.top.equalTo(self.safeAreaLayoutGuide).offset(self.appearance.insets.top)
            }

            make.bottom.lessThanOrEqualToSuperview()
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }
    }
}
