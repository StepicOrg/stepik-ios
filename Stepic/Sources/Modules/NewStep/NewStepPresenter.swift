import PromiseKit
import UIKit

protocol NewStepPresenterProtocol {
    func presentStep(response: NewStep.StepLoad.Response)
    func presentStepTextUpdate(response: NewStep.StepTextUpdate.Response)
    func presentControlsUpdate(response: NewStep.ControlsUpdate.Response)
    func presentDiscussionsButtonUpdate(response: NewStep.DiscussionsButtonUpdate.Response)
    func presentDiscussions(response: NewStep.DiscussionsPresentation.Response)
}

final class NewStepPresenter: NewStepPresenterProtocol {
    weak var viewController: NewStepViewControllerProtocol?

    func presentStep(response: NewStep.StepLoad.Response) {
        if case .success(let data) = response.result {
            self.makeViewModel(
                step: data.step,
                fontSize: data.fontSize
            ).done(on: .global(qos: .userInitiated)) { viewModel in
                DispatchQueue.main.async { [weak self] in
                    self?.viewController?.displayStep(
                        viewModel: NewStep.StepLoad.ViewModel(state: .result(data: viewModel))
                    )
                }
            }

            return
        }

        if case .failure = response.result {
            self.viewController?.displayStep(viewModel: NewStep.StepLoad.ViewModel(state: .error))
        }
    }

    func presentStepTextUpdate(response: NewStep.StepTextUpdate.Response) {
        let htmlString = self.makeProcessedContentHTMLString(
            response.text,
            fontSize: response.fontSize
        )

        self.viewController?.displayStepTextUpdate(viewModel: .init(htmlText: htmlString))
    }

    func presentControlsUpdate(response: NewStep.ControlsUpdate.Response) {
        let viewModel = NewStep.ControlsUpdate.ViewModel(
            canNavigateToPreviousUnit: response.canNavigateToPreviousUnit,
            canNavigateToNextUnit: response.canNavigateToNextUnit,
            canNavigateToNextStep: response.canNavigateToNextStep
        )

        self.viewController?.displayControlsUpdate(viewModel: viewModel)
    }

    func presentDiscussionsButtonUpdate(response: NewStep.DiscussionsButtonUpdate.Response) {
        self.viewController?.displayDiscussionsButtonUpdate(
            viewModel: .init(
                title: self.makeDiscussionsLabelTitle(step: response.step),
                isEnabled: response.step.discussionProxyID != nil
            )
        )
    }

    func presentDiscussions(response: NewStep.DiscussionsPresentation.Response) {
        guard let discussionProxyID = response.step.discussionProxyID else {
            return
        }

        self.viewController?.displayDiscussions(
            viewModel: .init(
                discussionProxyID: discussionProxyID,
                stepID: response.step.id,
                embeddedInWriteComment: (response.step.discussionsCount ?? 0) == 0
            )
        )
    }

    // MARK: Private API

    private func makeViewModel(step: Step, fontSize: FontSize) -> Guarantee<NewStepViewModel> {
        Guarantee { seal in
            let contentType: NewStepViewModel.ContentType = {
                switch step.block.type {
                case .video:
                    if let video = step.block.video {
                        let viewModel = NewStepVideoViewModel(
                            video: video,
                            videoThumbnailImageURL: URL(string: video.thumbnailURL)
                        )
                        return .video(viewModel: viewModel)
                    }
                    return .video(viewModel: nil)
                default:
                    let htmlString = self.makeProcessedContentHTMLString(
                        step.block.text ?? "",
                        fontSize: fontSize
                    )
                    return .text(htmlString: htmlString)
                }
            }()

            let quizType: NewStep.QuizType?
            switch step.block.type {
            case .text, .video:
                quizType = nil
            default:
                quizType = NewStep.QuizType(blockName: step.block.name)
            }

            let discussionsLabelTitle = self.makeDiscussionsLabelTitle(step: step)
            let urlPath = "\(StepicApplicationsInfo.stepicURL)/lesson/\(step.lessonID)/step/\(step.position)?from_mobile_app=true"

            let viewModel = NewStepViewModel(
                content: contentType,
                quizType: quizType,
                discussionsLabelTitle: discussionsLabelTitle,
                isDiscussionsEnabled: step.discussionProxyID != nil,
                discussionProxyID: step.discussionProxyID,
                stepURLPath: urlPath,
                lessonID: step.lessonID,
                passedByCount: step.block.type.isQuiz ? step.passedByCount : nil,
                correctRatio: step.block.type.isQuiz ? step.correctRatio : nil,
                step: step
            )

            seal(viewModel)
        }
    }

    private func makeDiscussionsLabelTitle(step: Step) -> String {
        if step.discussionProxyID == nil {
            return NSLocalizedString("DisabledDiscussionsButtonTitle", comment: "")
        }

        if let discussionsCount = step.discussionsCount, discussionsCount > 0 {
            return String(
                format: NSLocalizedString("DiscussionsButtonTitle", comment: ""),
                FormatterHelper.longNumber(discussionsCount)
            )
        }

        return NSLocalizedString("NoDiscussionsButtonTitle", comment: "")
    }

    private func makeProcessedContentHTMLString(_ text: String, fontSize: FontSize) -> String {
        var injections = ContentProcessor.defaultInjections
        injections.append(FontSizeInjection(fontSize: fontSize))

        let contentProcessor = ContentProcessor(
            content: text,
            rules: ContentProcessor.defaultRules,
            injections: injections
        )

        return contentProcessor.processContent()
    }
}
