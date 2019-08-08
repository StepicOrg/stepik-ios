import UIKit

protocol NewLessonPresenterProtocol {
    func presentLesson(response: NewLesson.LessonLoad.Response)
    func presentLessonNavigation(response: NewLesson.LessonNavigationLoad.Response)
    func presentLessonTooltipInfo(response: NewLesson.LessonTooltipInfoLoad.Response)
    func presentStepPassedStatusUpdate(response: NewLesson.StepPassedStatusUpdate.Response)
    func presentCurrentStepUpdate(response: NewLesson.CurrentStepUpdate.Response)
}

final class NewLessonPresenter: NewLessonPresenterProtocol {
    weak var viewController: NewLessonViewControllerProtocol?

    func presentLesson(response: NewLesson.LessonLoad.Response) {
        let viewModel: NewLesson.LessonLoad.ViewModel

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
                        startStepIndex: result.startStepIndex
                    )
                )
            )
        }

        self.viewController?.displayLesson(viewModel: viewModel)
    }

    func presentLessonNavigation(response: NewLesson.LessonNavigationLoad.Response) {
        let viewModel = NewLesson.LessonNavigationLoad.ViewModel(
            hasPreviousUnit: response.hasPreviousUnit,
            hasNextUnit: response.hasNextUnit
        )

        self.viewController?.displayLessonNavigation(viewModel: viewModel)
    }

    func presentLessonTooltipInfo(response: NewLesson.LessonTooltipInfoLoad.Response) {
        var data: [Step.IdType: [NewLesson.TooltipInfo]] = [:]

        for (step, progress) in zip(response.steps, response.progresses) {
            var infos: [NewLesson.TooltipInfo] = []

            if progress.score > 0 {
                let text = String(
                    format: NSLocalizedString("LessonTooltipPointsWithScoreTitle", comment: ""),
                    FormatterHelper.pointsCount(progress.score),
                    "\(progress.cost)"
                )
                infos.append(.init(iconImage: UIImage(named: "lesson-tooltip-check"), text: text))
            } else if progress.cost > 0 {
                let text = String(
                    format: NSLocalizedString("LessonTooltipPointsTitle", comment: ""),
                    FormatterHelper.pointsCount(progress.cost)
                )
                infos.append(.init(iconImage: UIImage(named: "lesson-tooltip-check"), text: text))
            }

            let timeToCompleteString: String = {
                let timeToComplete = response.lesson.timeToComplete > 60
                    ? response.lesson.timeToComplete
                    : Double(response.lesson.stepsArray.count) * 60.0

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
            infos.append(.init(iconImage: UIImage(named: "lesson-tooltip-duration"), text: lessonTooltipTimeToComplete))

            data[step.id] = infos
        }

        self.viewController?.displayLessonTooltipInfo(viewModel: .init(data: data))
    }

    func presentStepPassedStatusUpdate(response: NewLesson.StepPassedStatusUpdate.Response) {
        self.viewController?.displayStepPassedStatusUpdate(viewModel: .init(stepID: response.stepID))
    }

    func presentCurrentStepUpdate(response: NewLesson.CurrentStepUpdate.Response) {
        self.viewController?.displayCurrentStepUpdate(viewModel: .init(index: response.index))
    }

    // MAKE: Private API

    private func makeViewModel(
        lesson: Lesson,
        steps: [Step],
        progresses: [Progress],
        startStepIndex: Int
    ) -> NewLessonViewModel {
        let lessonTitle = lesson.title
        let steps: [NewLessonViewModel.StepDescription] = steps.enumerated().map { index, step in
            let iconImage: UIImage? = {
                switch step.block.name {
                case "video":
                    return UIImage(named: "video_step_icon")
                case "text":
                    return UIImage(named: "theory_step_icon")
                case "code", "dataset", "admin", "sql":
                    return UIImage(named: "code_step_icon")
                default:
                    return UIImage(named: "quiz_step_icon")
                }
            }()
            return .init(
                id: step.id,
                iconImage: iconImage ?? UIImage(),
                isPassed: progresses[safe: index]?.isPassed ?? false
            )
        }
        return NewLessonViewModel(
            lessonTitle: lessonTitle,
            steps: steps,
            stepLinkMaker: {
                "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.id)/step/\($0)?from_mobile_app=true"
            },
            startStepIndex: startStepIndex
        )
    }
}
