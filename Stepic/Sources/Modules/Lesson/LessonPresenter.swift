import UIKit

protocol LessonPresenterProtocol {
    func presentLesson(response: LessonDataFlow.LessonLoad.Response)
    func presentLessonNavigation(response: LessonDataFlow.LessonNavigationLoad.Response)
    func presentLessonTooltipInfo(response: LessonDataFlow.LessonTooltipInfoLoad.Response)
    func presentLessonModule(response: LessonDataFlow.LessonModulePresentation.Response)
    func presentStepTooltipInfoUpdate(response: LessonDataFlow.StepTooltipInfoUpdate.Response)
    func presentStepPassedStatusUpdate(response: LessonDataFlow.StepPassedStatusUpdate.Response)
    func presentCurrentStepUpdate(response: LessonDataFlow.CurrentStepUpdate.Response)
    func presentCurrentStepAutoplay(response: LessonDataFlow.CurrentStepAutoplay.Response)
    func presentEditStep(response: LessonDataFlow.EditStepPresentation.Response)
    func presentSubmissions(response: LessonDataFlow.SubmissionsPresentation.Response)
    func presentStepTextUpdate(response: LessonDataFlow.StepTextUpdate.Response)
    func presentWaitingState(response: LessonDataFlow.BlockingWaitingIndicatorUpdate.Response)
    func presentLessonUnitNavigationRequirementNotSatisfied(
        response: LessonDataFlow.LessonUnitNavigationRequirementNotSatisfiedPresentation.Response
    )
    func presentLessonUnitNavigationError(response: LessonDataFlow.LessonUnitNavigationErrorPresentation.Response)
    func presentLessonUnitNavigationExam(response: LessonDataFlow.LessonUnitNavigationExamPresentation.Response)
}

final class LessonPresenter: LessonPresenterProtocol {
    weak var viewController: LessonViewControllerProtocol?

    private let urlFactory: StepikURLFactory

    init(urlFactory: StepikURLFactory) {
        self.urlFactory = urlFactory
    }

    func presentLesson(response: LessonDataFlow.LessonLoad.Response) {
        let viewModel: LessonDataFlow.LessonLoad.ViewModel

        switch response.state {
        case .failure:
            viewModel = .init(state: .error)
        case .success(let result):
            viewModel = .init(
                state: .result(
                    data: self.makeViewModel(
                        lesson: result.lesson,
                        steps: result.steps,
                        progresses: result.progresses,
                        startStepIndex: result.startStepIndex,
                        canEdit: result.canEdit
                    )
                )
            )
        }

        self.viewController?.displayLesson(viewModel: viewModel)
    }

    func presentLessonNavigation(response: LessonDataFlow.LessonNavigationLoad.Response) {
        let viewModel = LessonDataFlow.LessonNavigationLoad.ViewModel(
            hasPreviousUnit: response.hasPreviousUnit,
            hasNextUnit: response.hasNextUnit
        )

        self.viewController?.displayLessonNavigation(viewModel: viewModel)
    }

    func presentLessonTooltipInfo(response: LessonDataFlow.LessonTooltipInfoLoad.Response) {
        var data: [Step.IdType: [LessonDataFlow.TooltipInfo]] = [:]
        zip(response.steps, response.progresses).forEach { step, progress in
            data[step.id] = self.makeTooltipInfoViewModel(lesson: response.lesson, progress: progress)
        }

        self.viewController?.displayLessonTooltipInfo(viewModel: .init(data: data))
    }

    func presentLessonModule(response: LessonDataFlow.LessonModulePresentation.Response) {
        self.viewController?.displayLessonModule(
            viewModel: .init(lessonID: response.lessonID, stepIndex: response.stepIndex)
        )
    }

    func presentStepTooltipInfoUpdate(response: LessonDataFlow.StepTooltipInfoUpdate.Response) {
        self.viewController?.displayStepTooltipInfoUpdate(
            viewModel: .init(
                stepID: response.step.id,
                info: self.makeTooltipInfoViewModel(lesson: response.lesson, progress: response.progress)
            )
        )
    }

    func presentStepPassedStatusUpdate(response: LessonDataFlow.StepPassedStatusUpdate.Response) {
        self.viewController?.displayStepPassedStatusUpdate(viewModel: .init(stepID: response.stepID))
    }

    func presentCurrentStepUpdate(response: LessonDataFlow.CurrentStepUpdate.Response) {
        self.viewController?.displayCurrentStepUpdate(viewModel: .init(index: response.index))
    }

    func presentCurrentStepAutoplay(response: LessonDataFlow.CurrentStepAutoplay.Response) {
        self.viewController?.displayCurrentStepAutoplay(viewModel: .init())
    }

    func presentStepTextUpdate(response: LessonDataFlow.StepTextUpdate.Response) {
        self.viewController?.displayStepTextUpdate(
            viewModel: .init(index: response.index, text: response.stepSource.text)
        )
    }

    func presentEditStep(response: LessonDataFlow.EditStepPresentation.Response) {
        self.viewController?.displayEditStep(viewModel: .init(stepID: response.stepID))
    }

    func presentSubmissions(response: LessonDataFlow.SubmissionsPresentation.Response) {
        self.viewController?.displaySubmissions(
            viewModel: .init(stepID: response.stepID, isTeacher: response.isTeacher)
        )
    }

    func presentWaitingState(response: LessonDataFlow.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    func presentLessonUnitNavigationRequirementNotSatisfied(
        response: LessonDataFlow.LessonUnitNavigationRequirementNotSatisfiedPresentation.Response
    ) {
        let title = String(
            format: NSLocalizedString("LessonUnitNavigationFinishedModuleTitle", comment: ""),
            arguments: [response.currentSection.title]
        )

        let requiredPointsCount: String = {
            guard let requiredSectionProgress = response.requiredSection.progress else {
                return FormatterHelper.pointsCount(0).replacingOccurrences(of: "0", with: "N/A")
            }

            let requiredPoints = Int(
                (Float(requiredSectionProgress.cost) * Float(response.targetSection.requiredPercent) / 100).rounded(.up)
            )

            return FormatterHelper.pointsCount(requiredPoints)
        }()

        let message = String(
            format: NSLocalizedString("LessonUnitNavigationRequirementNotSatisfiedMessage", comment: ""),
            arguments: [response.targetSection.title, requiredPointsCount, response.requiredSection.title]
        )

        self.viewController?.displayLessonUnitNavigationRequirementNotSatisfied(
            viewModel: .init(title: title, message: message)
        )
    }

    func presentLessonUnitNavigationError(response: LessonDataFlow.LessonUnitNavigationErrorPresentation.Response) {
        let title = NSLocalizedString("Error", comment: "")
        let message = String(
            format: NSLocalizedString("LessonUnitNavigationCommonErrorMessage", comment: ""),
            arguments: [response.targetSection.title]
        )

        self.viewController?.displayLessonUnitNavigationError(viewModel: .init(title: title, message: message))
    }

    func presentLessonUnitNavigationExam(response: LessonDataFlow.LessonUnitNavigationExamPresentation.Response) {
        let title = String(
            format: NSLocalizedString("LessonUnitNavigationFinishedModuleTitle", comment: ""),
            arguments: [response.currentSection.title]
        )

        let message = String(
            format: NSLocalizedString("LessonUnitNavigationExamMessage", comment: ""),
            arguments: [response.targetSection.title]
        )

        self.viewController?.displayLessonUnitNavigationExam(viewModel: .init(title: title, message: message))
    }

    // MAKE: Private API

    private func makeViewModel(
        lesson: Lesson,
        steps: [Step],
        progresses: [Progress],
        startStepIndex: Int,
        canEdit: Bool
    ) -> LessonViewModel {
        let steps: [LessonViewModel.StepDescription] = steps.enumerated().map { index, step in
            let iconImage: UIImage? = {
                if step.hasReview {
                    return UIImage(named: "ic_peer_review")?.withRenderingMode(.alwaysTemplate)
                }

                switch step.block.type {
                case .video:
                    return UIImage(named: "video_step_icon")
                case .text:
                    return UIImage(named: "theory_step_icon")
                case .code, .dataset, .admin, .sql:
                    return UIImage(named: "code_step_icon")
                default:
                    return UIImage(named: "quiz_step_icon")
                }
            }()
            return .init(
                id: step.id,
                iconImage: iconImage ?? UIImage(),
                isPassed: progresses[safe: index]?.isPassed ?? false,
                canEdit: canEdit && step.block.type != .video,
                isQuiz: !(step.block.type?.isTheory ?? false)
            )
        }

        return LessonViewModel(
            lessonTitle: FormatterHelper.lessonTitle(lesson),
            steps: steps,
            stepLinkMaker: { self.urlFactory.makeStep(lessonID: lesson.id, stepPosition: $0, fromMobile: true) },
            startStepIndex: startStepIndex
        )
    }

    private func makeTooltipInfoViewModel(lesson: Lesson, progress: Progress) -> [LessonDataFlow.TooltipInfo] {
        var viewModel: [LessonDataFlow.TooltipInfo] = []

        if progress.score > 0 {
            let hasDecimals = progress.score.truncatingRemainder(dividingBy: 1) != 0
            let text = hasDecimals
                ? String(
                    format: NSLocalizedString("LessonTooltipPointsWithScoreTitle", comment: ""),
                    "\(FormatterHelper.progressScore(progress.score)) \(NSLocalizedString("points234", comment: ""))",
                    "\(progress.cost)"
                )
                : String(
                    format: NSLocalizedString("LessonTooltipPointsWithScoreTitle", comment: ""),
                    FormatterHelper.pointsCount(Int(progress.score)),
                    "\(progress.cost)"
                )
            viewModel.append(.init(iconImage: UIImage(named: "lesson-tooltip-check"), text: text))
        } else if progress.cost > 0 {
            let text = String(
                format: NSLocalizedString("LessonTooltipPointsTitle", comment: ""),
                FormatterHelper.pointsCount(progress.cost)
            )
            viewModel.append(.init(iconImage: UIImage(named: "lesson-tooltip-check"), text: text))
        }

        let timeToCompleteString: String = {
            let timeToComplete = lesson.timeToComplete > 60
                ? lesson.timeToComplete
                : Double(lesson.stepsArray.count) * 60.0
            if case 60..<3600 = timeToComplete {
                return FormatterHelper.minutesInSeconds(timeToComplete, roundingRule: .down)
            } else {
                return FormatterHelper.hoursInSeconds(timeToComplete, roundingRule: .down)
            }
        }()

        let lessonTooltipTimeToComplete = String(
            format: NSLocalizedString("LessonTooltipTimeToCompleteTitle", comment: ""),
            timeToCompleteString
        )
        viewModel.append(.init(iconImage: UIImage(named: "lesson-tooltip-duration"), text: lessonTooltipTimeToComplete))

        return viewModel
    }
}
