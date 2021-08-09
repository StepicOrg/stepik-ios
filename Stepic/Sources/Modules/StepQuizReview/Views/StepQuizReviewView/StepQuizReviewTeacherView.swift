import SnapKit
import UIKit

extension StepQuizReviewTeacherView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground
        let insets = LayoutInsets.default

        let actionButtonMinHeight: CGFloat = 44

        let stackViewSpacing: CGFloat = 16
    }
}

final class StepQuizReviewTeacherView: UIView, StepQuizReviewViewProtocol {
    weak var delegate: StepQuizReviewViewDelegate?

    let appearance: Appearance
    private var storedViewModel: StepQuizReviewViewModel?

    private lazy var messageView = StepQuizReviewMessageView()

    private lazy var primaryActionButton: UIButton = {
        let button = LessonPanModalActionButton()
        button.addTarget(self, action: #selector(self.primaryActionButtonClicked), for: .touchUpInside)
        return button
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

    func configure(viewModel: StepQuizReviewViewModel) {
        self.messageView.title = viewModel.infoMessage

        self.primaryActionButton.setTitle(viewModel.primaryActionButtonDescription.title, for: .normal)
        self.primaryActionButton.isEnabled = viewModel.primaryActionButtonDescription.isEnabled
        self.primaryActionButton.alpha = self.primaryActionButton.isEnabled ? 1.0 : 0.5

        self.storedViewModel = viewModel
    }

    @objc
    private func primaryActionButtonClicked() {
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
        self.stackView.addArrangedSubview(self.messageView)
        self.stackView.addArrangedSubview(self.primaryActionButton)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalTo(self.appearance.insets.edgeInsets)
        }

        self.primaryActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.primaryActionButton.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(self.appearance.actionButtonMinHeight)
        }
    }
}
