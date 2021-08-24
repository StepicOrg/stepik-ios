import SnapKit
import UIKit

// swiftlint:disable file_length
extension StepQuizReviewView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground
        let insets = LayoutInsets.default

        let messageViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)

        let solutionViewInsets = LayoutInsets(top: 0, left: -16, bottom: 0, right: -16)

        let stackViewSpacing: CGFloat = 0
        let stackViewInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

        let actionButtonHeight: CGFloat = 44
        let actionButtonsSpacing: CGFloat = 16
    }
}

final class StepQuizReviewView: UIView, StepQuizReviewViewProtocol {
    weak var delegate: StepQuizReviewViewDelegate?

    let appearance: Appearance
    private var storedViewModel: StepQuizReviewViewModel?

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

    private lazy var solutionContainerView: UIView = {
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

    func addSolution(view: UIView) {
        self.solutionContainerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.solutionViewInsets.edgeInsets)
        }
    }

    func configure(viewModel: StepQuizReviewViewModel) {
        self.storedViewModel = viewModel

        self.messageView.title = viewModel.infoMessage
        self.messageContainerView.isHidden = self.messageView.title?.isEmpty ?? true

        self.quizContainerView.isHidden = true
        self.solutionContainerView.isHidden = true
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
        let statusContainerView1 = self.makeStage1StatusContainerView(viewModel)
        self.statusesView.addArrangedReviewStatus(statusContainerView1)

        // 2
        let statusContainerView2 = self.makeStage2StatusContainerView(viewModel)
        self.statusesView.addArrangedReviewStatus(statusContainerView2)

        // 3
        let statusView3 = StepQuizReviewStatusView()
        statusView3.position = 3
        statusView3.isLastPosition = true
        statusView3.status = { () -> StepQuizReviewStatusView.Status in
            switch stage {
            case .submissionNotMade, .submissionNotSelected:
                return .pending
            case .submissionSelected:
                return .inProgress
            case .completed:
                return .completed
            }
        }()
        statusView3.title = { () -> String in
            let defaultStringValue = "n/a"

            if statusView3.status == .completed {
                let formattedScore = viewModel.score != nil ? "\(viewModel.score.require())" : defaultStringValue

                let formattedCost: String
                if let cost = viewModel.cost {
                    formattedCost = cost == 1
                        ? "\(cost) \(NSLocalizedString("points234", comment: ""))"
                        : "\(cost) \(NSLocalizedString("points567890", comment: ""))"
                } else {
                    formattedCost = "\(defaultStringValue) \(NSLocalizedString("points567890", comment: ""))"
                }

                return String(
                    format: NSLocalizedString("StepQuizReviewInstructorCompleted", comment: ""),
                    arguments: [formattedScore, formattedCost]
                )
            } else {
                let formattedCost: String
                if let cost = viewModel.cost {
                    formattedCost = FormatterHelper.pointsCount(cost)
                } else {
                    formattedCost = "\(defaultStringValue) \(NSLocalizedString("points567890", comment: ""))"
                }

                return String(
                    format: NSLocalizedString("StepQuizReviewInstructorPending", comment: ""),
                    arguments: [formattedCost]
                )
            }
        }()

        weak var primaryActionButton3: UIButton?

        let contentView3: UIView? = {
            switch statusView3.status {
            case .error, .pending:
                return nil
            case .inProgress:
                let messageView = StepQuizReviewMessageView()
                messageView.title = NSLocalizedString("StepQuizReviewInstructorCompletedHint", comment: "")
                return messageView
            case .completed:
                let button = self.makePrimaryActionButton(
                    description: viewModel.primaryActionButtonDescription,
                    isFilled: false
                )
                primaryActionButton3 = button
                return button
            }
        }()

        let statusContainerView3 = StepQuizReviewStatusContainerView(
            headerView: statusView3,
            contentView: contentView3,
            shouldShowSeparator: true
        )
        self.statusesView.addArrangedReviewStatus(statusContainerView3)

        if let primaryActionButton3 = primaryActionButton3 {
            primaryActionButton3.translatesAutoresizingMaskIntoConstraints = false
            primaryActionButton3.snp.makeConstraints { make in
                make.height.equalTo(self.appearance.actionButtonHeight)
            }
        }
    }

    private func configurePeerReview(_ viewModel: StepQuizReviewViewModel) {
        let stage = viewModel.stage ?? .submissionNotMade

        // 1
        let statusContainerView1 = self.makeStage1StatusContainerView(viewModel)
        self.statusesView.addArrangedReviewStatus(statusContainerView1)

        // 2
        let statusContainerView2 = self.makeStage2StatusContainerView(viewModel)
        self.statusesView.addArrangedReviewStatus(statusContainerView2)

        // 3
        let statusView3 = StepQuizReviewStatusView(shouldShowSeparator: false)
        statusView3.position = 3
        statusView3.status = { () -> StepQuizReviewStatusView.Status in
            switch stage {
            case .submissionNotMade, .submissionNotSelected:
                return .pending
            case .submissionSelected:
                return .inProgress
            case .completed:
                return .completed
            }
        }()
        statusView3.title = { () -> String in
            switch statusView3.status {
            case .error, .pending:
                return NSLocalizedString("StepQuizReviewGivenPendingZero", comment: "")
            case .inProgress:
                guard let minReviewsCount = viewModel.minReviewsCount,
                      let givenReviewsCount = viewModel.givenReviewsCount else {
                    return NSLocalizedString("StepQuizReviewGivenPendingZero", comment: "")
                }

                let remainingReviewsCount = minReviewsCount - givenReviewsCount

                if remainingReviewsCount > 0 {
                    if givenReviewsCount > 0 {
                        let pluralizedCountString = StringHelper.pluralize(
                            number: remainingReviewsCount,
                            forms: [
                                NSLocalizedString("StepQuizReviewGivenInProgress1", comment: ""),
                                NSLocalizedString("StepQuizReviewGivenInProgress234", comment: ""),
                                NSLocalizedString("StepQuizReviewGivenInProgress567890", comment: "")
                            ]
                        )
                        return String(
                            format: pluralizedCountString,
                            arguments: ["\(remainingReviewsCount)", self.makeGivenReviewsCountString(givenReviewsCount)]
                        )
                    } else {
                        let pluralizedCountString = StringHelper.pluralize(
                            number: minReviewsCount,
                            forms: [
                                NSLocalizedString("StepQuizReviewGivenInProgressZero1", comment: ""),
                                NSLocalizedString("StepQuizReviewGivenInProgressZero234", comment: ""),
                                NSLocalizedString("StepQuizReviewGivenInProgressZero567890", comment: "")
                            ]
                        )
                        return String(format: pluralizedCountString, arguments: ["\(minReviewsCount)"])
                    }
                } else if givenReviewsCount > 0 {
                    return self.makeGivenReviewsCountString(givenReviewsCount)
                } else {
                    return NSLocalizedString("StepQuizReviewGivenPendingZero", comment: "")
                }
            case .completed:
                return self.makeGivenReviewsCountString(viewModel.givenReviewsCount ?? 0)
            }
        }()

        weak var primaryActionButton3: UIButton?

        let contentView3: UIView? = {
            switch statusView3.status {
            case .error, .pending:
                return nil
            case .inProgress:
                guard let minReviewsCount = viewModel.minReviewsCount,
                      let givenReviewsCount = viewModel.givenReviewsCount,
                      let isReviewAvailable = viewModel.isReviewAvailable else {
                    return nil
                }

                let remainingReviewsCount = minReviewsCount - givenReviewsCount

                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = self.appearance.actionButtonsSpacing

                if remainingReviewsCount > 0 {
                    if isReviewAvailable {
                        let primaryButton = self.makePrimaryActionButton(
                            description: .init(
                                title: NSLocalizedString("StepQuizReviewGivenInProgressAction", comment: ""),
                                isEnabled: true,
                                uniqueIdentifier: StepQuizReview.ActionType.studentWriteReviews.uniqueIdentifier
                            ),
                            isFilled: true
                        )
                        primaryButton.addTarget(
                            self,
                            action: #selector(self.writeReviewsClicked),
                            for: .touchUpInside
                        )

                        stackView.addArrangedSubview(primaryButton)

                        primaryButton.translatesAutoresizingMaskIntoConstraints = false
                        primaryButton.snp.makeConstraints { $0.height.equalTo(self.appearance.actionButtonHeight) }
                    } else {
                        let primaryButton = self.makePrimaryActionButton(
                            description: .init(
                                title: NSLocalizedString("StepQuizReviewGivenNoReview", comment: ""),
                                isEnabled: false,
                                uniqueIdentifier: ""
                            ),
                            isFilled: true
                        )

                        stackView.addArrangedSubview(primaryButton)

                        primaryButton.translatesAutoresizingMaskIntoConstraints = false
                        primaryButton.snp.makeConstraints { $0.height.equalTo(self.appearance.actionButtonHeight) }
                    }

                    if givenReviewsCount > 0 {
                        let secondaryButton = self.makePrimaryActionButton(
                            description: .init(
                                title: NSLocalizedString("StepQuizReviewGivenCompletedAction", comment: ""),
                                isEnabled: true,
                                uniqueIdentifier: StepQuizReview.ActionType.studentViewGivenReviews.uniqueIdentifier
                            ),
                            isFilled: false
                        )
                        secondaryButton.addTarget(
                            self,
                            action: #selector(self.viewGivenReviewsClicked),
                            for: .touchUpInside
                        )

                        stackView.addArrangedSubview(secondaryButton)

                        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
                        secondaryButton.snp.makeConstraints { $0.height.equalTo(self.appearance.actionButtonHeight) }
                    }

                    return stackView
                } else if givenReviewsCount > 0 {
                    if isReviewAvailable {
                        let messageView = StepQuizReviewMessageView()
                        messageView.title = NSLocalizedString("StepQuizReviewGivenExtraNote", comment: "")
                        stackView.addArrangedSubview(messageView)

                        let primaryButton = self.makePrimaryActionButton(
                            description: .init(
                                title: NSLocalizedString("StepQuizReviewGivenInProgressContinueAction", comment: ""),
                                isEnabled: true,
                                uniqueIdentifier: StepQuizReview.ActionType.studentWriteReviews.uniqueIdentifier
                            ),
                            isFilled: false
                        )
                        primaryButton.addTarget(
                            self,
                            action: #selector(self.writeReviewsClicked),
                            for: .touchUpInside
                        )

                        stackView.addArrangedSubview(primaryButton)

                        primaryButton.translatesAutoresizingMaskIntoConstraints = false
                        primaryButton.snp.makeConstraints { $0.height.equalTo(self.appearance.actionButtonHeight) }
                    } else {
                        let secondaryButton = self.makePrimaryActionButton(
                            description: .init(
                                title: NSLocalizedString("StepQuizReviewGivenCompletedAction", comment: ""),
                                isEnabled: true,
                                uniqueIdentifier: StepQuizReview.ActionType.studentViewGivenReviews.uniqueIdentifier
                            ),
                            isFilled: false
                        )
                        secondaryButton.addTarget(
                            self,
                            action: #selector(self.viewGivenReviewsClicked),
                            for: .touchUpInside
                        )

                        stackView.addArrangedSubview(secondaryButton)

                        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
                        secondaryButton.snp.makeConstraints { $0.height.equalTo(self.appearance.actionButtonHeight) }
                    }

                    return stackView
                } else {
                    return nil
                }
            case .completed:
                let secondaryButton = self.makePrimaryActionButton(
                    description: .init(
                        title: NSLocalizedString("StepQuizReviewGivenCompletedAction", comment: ""),
                        isEnabled: true,
                        uniqueIdentifier: StepQuizReview.ActionType.studentViewGivenReviews.uniqueIdentifier
                    ),
                    isFilled: false
                )
                secondaryButton.addTarget(
                    self,
                    action: #selector(self.viewGivenReviewsClicked),
                    for: .touchUpInside
                )

                stackView.addArrangedSubview(secondaryButton)

                secondaryButton.translatesAutoresizingMaskIntoConstraints = false
                secondaryButton.snp.makeConstraints { $0.height.equalTo(self.appearance.actionButtonHeight) }

                primaryActionButton3 = secondaryButton

                return secondaryButton
            }
        }()

        var statusContainerView3Appearance = StepQuizReviewStatusContainerView.Appearance()
        statusContainerView3Appearance.contentViewInsets.top = 0
        let statusContainerView3 = StepQuizReviewStatusContainerView(
            headerView: statusView3,
            contentView: contentView3,
            shouldShowSeparator: contentView3 != nil,
            appearance: statusContainerView3Appearance
        )
        self.statusesView.addArrangedReviewStatus(statusContainerView3)

        if let primaryActionButton3 = primaryActionButton3 {
            primaryActionButton3.translatesAutoresizingMaskIntoConstraints = false
            primaryActionButton3.snp.makeConstraints { make in
                make.height.equalTo(self.appearance.actionButtonHeight)
            }
        }

        // 4
        let statusView4 = StepQuizReviewStatusView(shouldShowSeparator: false)
        statusView4.position = 4
        statusView4.status = statusView3.status
        statusView4.title = { () -> String in
            switch statusView4.status {
            case .error, .pending:
                return NSLocalizedString("StepQuizReviewTakenPendingZero", comment: "")
            case .inProgress:
                guard let minReviewsCount = viewModel.minReviewsCount,
                      let takenReviewsCount = viewModel.takenReviewsCount else {
                    return NSLocalizedString("StepQuizReviewTakenPendingZero", comment: "")
                }

                let remainingReviewsCount = minReviewsCount - takenReviewsCount

                if remainingReviewsCount > 0 {
                    if takenReviewsCount > 0 {
                        let pluralizedCountString = StringHelper.pluralize(
                            number: remainingReviewsCount,
                            forms: [
                                NSLocalizedString("StepQuizReviewTakenInProgress1", comment: ""),
                                NSLocalizedString("StepQuizReviewTakenInProgress234", comment: ""),
                                NSLocalizedString("StepQuizReviewTakenInProgress567890", comment: "")
                            ]
                        )
                        return String(
                            format: pluralizedCountString,
                            arguments: ["\(remainingReviewsCount)", self.makeTakenReviewsCountString(takenReviewsCount)]
                        )
                    } else {
                        let pluralizedCountString = StringHelper.pluralize(
                            number: minReviewsCount,
                            forms: [
                                NSLocalizedString("StepQuizReviewTakenInProgressZero1", comment: ""),
                                NSLocalizedString("StepQuizReviewTakenInProgressZero234", comment: ""),
                                NSLocalizedString("StepQuizReviewTakenInProgressZero567890", comment: "")
                            ]
                        )
                        return String(format: pluralizedCountString, arguments: ["\(minReviewsCount)"])
                    }
                } else if takenReviewsCount > 0 {
                    return self.makeTakenReviewsCountString(takenReviewsCount)
                } else {
                    return NSLocalizedString("StepQuizReviewTakenPendingZero", comment: "")
                }
            case .completed:
                return self.makeTakenReviewsCountString(viewModel.takenReviewsCount ?? 0)
            }
        }()

        let contentView4: UIView? = {
            let primaryActionButton = self.makePrimaryActionButton(
                description: .init(
                    title: NSLocalizedString("StepQuizReviewTakenAction", comment: ""),
                    isEnabled: true,
                    uniqueIdentifier: StepQuizReview.ActionType.studentViewTakenReviews.uniqueIdentifier
                ),
                isFilled: false
            )
            primaryActionButton.addTarget(self, action: #selector(self.viewTakenReviewsClicked), for: .touchUpInside)

            let primaryActionButtonContainerView = UIView()
            primaryActionButtonContainerView.addSubview(primaryActionButton)

            primaryActionButton.translatesAutoresizingMaskIntoConstraints = false
            primaryActionButton.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(self.appearance.actionButtonHeight)
            }

            switch statusView3.status {
            case .error, .pending:
                return nil
            case .inProgress:
                guard let takenReviewsCount = viewModel.takenReviewsCount else {
                    return nil
                }

                if takenReviewsCount > 0 {
                    return primaryActionButtonContainerView
                } else {
                    let messageView = StepQuizReviewMessageView()
                    messageView.title = NSLocalizedString("StepQuizReviewTakenHint", comment: "")
                    return messageView
                }
            case .completed:
                return primaryActionButton
            }
        }()

        var statusContainerView4Appearance = StepQuizReviewStatusContainerView.Appearance()
        statusContainerView4Appearance.contentViewInsets.top = 0
        let statusContainerView4 = StepQuizReviewStatusContainerView(
            headerView: statusView4,
            contentView: contentView4,
            shouldShowSeparator: contentView4 != nil,
            appearance: statusContainerView4Appearance
        )
        self.statusesView.addArrangedReviewStatus(statusContainerView4)

        // 5
        let statusView5 = StepQuizReviewStatusView()
        statusView5.position = 5
        statusView5.isLastPosition = true
        statusView5.status = stage == .completed ? .completed : .pending
        statusView5.title = { () -> String in
            guard let cost = viewModel.cost else {
                return NSLocalizedString("StepQuizReviewPeerPendingZero", comment: "")
            }

            if statusView5.status == .completed {
                let scoreString = viewModel.score != nil
                    ? FormatterHelper.submissionScore(viewModel.score.require())
                    : "n/a"
                let pluralizedCountString = StringHelper.pluralize(
                    number: cost,
                    forms: [
                        NSLocalizedString("StepQuizReviewPeerCompleted1", comment: ""),
                        NSLocalizedString("StepQuizReviewPeerCompleted234", comment: ""),
                        NSLocalizedString("StepQuizReviewPeerCompleted567890", comment: "")
                    ]
                )
                return String(
                    format: pluralizedCountString,
                    arguments: [scoreString, "\(cost)"]
                )
            } else {
                return String(
                    format: NSLocalizedString("StepQuizReviewPeerPending", comment: ""),
                    arguments: [FormatterHelper.pointsCount(cost)]
                )
            }
        }()
        let statusContainerView5 = StepQuizReviewStatusContainerView(headerView: statusView5)
        self.statusesView.addArrangedReviewStatus(statusContainerView5)
    }

    private func makeStage1StatusContainerView(
        _ viewModel: StepQuizReviewViewModel
    ) -> StepQuizReviewStatusContainerView {
        let statusView = StepQuizReviewStatusView()
        statusView.position = 1
        statusView.status = { () -> StepQuizReviewStatusView.Status in
            switch viewModel.stage ?? .submissionNotMade {
            case .submissionNotMade:
                return viewModel.isSubmissionWrong ? .error : .inProgress
            case .submissionNotSelected, .submissionSelected, .completed:
                return .completed
            }
        }()
        statusView.title = viewModel.quizTitle

        if statusView.status == .completed {
            return StepQuizReviewStatusContainerView(headerView: statusView)
        } else {
            self.quizContainerView.isHidden = false
            return StepQuizReviewStatusContainerView(
                headerView: statusView,
                contentView: self.quizContainerView,
                shouldShowSeparator: true
            )
        }
    }

    private func makeStage2StatusContainerView(
        _ viewModel: StepQuizReviewViewModel
    ) -> StepQuizReviewStatusContainerView {
        let statusView = StepQuizReviewStatusView()
        statusView.position = 2
        statusView.status = { () -> StepQuizReviewStatusView.Status in
            switch viewModel.stage ?? .submissionNotMade {
            case .submissionNotMade:
                return .pending
            case .submissionNotSelected:
                return .inProgress
            case .submissionSelected, .completed:
                return .completed
            }
        }()
        statusView.title = statusView.status == .completed
            ? NSLocalizedString("StepQuizReviewSendCompleted", comment: "")
            : NSLocalizedString("StepQuizReviewSendInProgress", comment: "")

        if statusView.status == .inProgress {
            self.quizContainerView.isHidden = false
            return StepQuizReviewStatusContainerView(
                headerView: statusView,
                contentView: self.quizContainerView,
                shouldShowSeparator: true
            )
        } else if statusView.status == .completed {
            self.solutionContainerView.isHidden = false
            return StepQuizReviewStatusContainerView(
                headerView: statusView,
                contentView: self.solutionContainerView,
                shouldShowSeparator: true
            )
        } else {
            return StepQuizReviewStatusContainerView(headerView: statusView)
        }
    }

    private func makePrimaryActionButton(
        description: StepQuizReviewViewModel.ButtonDescription,
        isFilled: Bool
    ) -> UIButton {
        let button = NextStepButton(style: isFilled ? .filled : .outlineGreen)
        button.isEnabled = description.isEnabled
        button.alpha = button.isEnabled ? 1.0 : 0.5
        button.setTitle(description.title, for: .normal)
        button.addTarget(self, action: #selector(self.primaryActionButtonClicked), for: .touchUpInside)
        return button
    }

    private func makeGivenReviewsCountString(_ count: Int) -> String {
        let formattedReviewsCount = FormatterHelper.quizReviewsCount(count)
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("StepQuizReviewGivenCompleted1", comment: ""),
                NSLocalizedString("StepQuizReviewGivenCompleted234", comment: ""),
                NSLocalizedString("StepQuizReviewGivenCompleted567890", comment: "")
            ]
        )
        return String(format: pluralizedCountString, arguments: [formattedReviewsCount])
    }

    private func makeTakenReviewsCountString(_ count: Int) -> String {
        let formattedReviewsCount = FormatterHelper.quizReviewsCount(count)
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("StepQuizReviewTakenCompleted1", comment: ""),
                NSLocalizedString("StepQuizReviewTakenCompleted234", comment: ""),
                NSLocalizedString("StepQuizReviewTakenCompleted567890", comment: "")
            ]
        )
        return String(format: pluralizedCountString, arguments: [formattedReviewsCount])
    }

    @objc
    private func primaryActionButtonClicked() {
        self.delegate?.stepQuizReviewViewView(
            self,
            didClickButtonWith: self.storedViewModel?.primaryActionButtonDescription.uniqueIdentifier
        )
    }

    @objc
    private func writeReviewsClicked() {
        self.delegate?.stepQuizReviewViewView(
            self,
            didClickButtonWith: StepQuizReview.ActionType.studentWriteReviews.uniqueIdentifier
        )
    }

    @objc
    private func viewGivenReviewsClicked() {
        self.delegate?.stepQuizReviewViewView(
            self,
            didClickButtonWith: StepQuizReview.ActionType.studentViewGivenReviews.uniqueIdentifier
        )
    }

    @objc
    private func viewTakenReviewsClicked() {
        self.delegate?.stepQuizReviewViewView(
            self,
            didClickButtonWith: StepQuizReview.ActionType.studentViewTakenReviews.uniqueIdentifier
        )
    }
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
