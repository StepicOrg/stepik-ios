import PromiseKit
import UIKit

protocol StepPresenterProtocol {
    func presentStep(response: StepDataFlow.StepLoad.Response)
    func presentStepTextUpdate(response: StepDataFlow.StepTextUpdate.Response)
    func presentPlayStep(response: StepDataFlow.PlayStep.Response)
    func presentControlsUpdate(response: StepDataFlow.ControlsUpdate.Response)
    func presentDiscussionsButtonUpdate(response: StepDataFlow.DiscussionsButtonUpdate.Response)
    func presentSolutionsButtonUpdate(response: StepDataFlow.SolutionsButtonUpdate.Response)
    func presentDiscussions(response: StepDataFlow.DiscussionsPresentation.Response)
    func presentSolutions(response: StepDataFlow.SolutionsPresentation.Response)
    func presentWaitingState(response: StepDataFlow.BlockingWaitingIndicatorUpdate.Response)
}

final class StepPresenter: StepPresenterProtocol {
    weak var viewController: StepViewControllerProtocol?

    func presentStep(response: StepDataFlow.StepLoad.Response) {
        if case .success(let data) = response.result {
            self.makeViewModel(
                step: data.step,
                fontSize: data.fontSize,
                storedImages: data.storedImages
            ).done(on: .global(qos: .userInitiated)) { viewModel in
                DispatchQueue.main.async { [weak self] in
                    self?.viewController?.displayStep(
                        viewModel: StepDataFlow.StepLoad.ViewModel(state: .result(data: viewModel))
                    )
                }
            }

            return
        }

        if case .failure = response.result {
            self.viewController?.displayStep(viewModel: StepDataFlow.StepLoad.ViewModel(state: .error))
        }
    }

    func presentStepTextUpdate(response: StepDataFlow.StepTextUpdate.Response) {
        let htmlString = self.makeProcessedContentHTMLString(
            response.text,
            fontSize: response.fontSize,
            storedImages: response.storedImages
        )

        self.viewController?.displayStepTextUpdate(viewModel: .init(htmlText: htmlString))
    }

    func presentPlayStep(response: StepDataFlow.PlayStep.Response) {
        self.viewController?.displayPlayStep(viewModel: .init())
    }

    func presentControlsUpdate(response: StepDataFlow.ControlsUpdate.Response) {
        let viewModel = StepDataFlow.ControlsUpdate.ViewModel(
            canNavigateToPreviousUnit: response.canNavigateToPreviousUnit,
            canNavigateToNextUnit: response.canNavigateToNextUnit,
            canNavigateToNextStep: response.canNavigateToNextStep
        )

        self.viewController?.displayControlsUpdate(viewModel: viewModel)
    }

    func presentDiscussionsButtonUpdate(response: StepDataFlow.DiscussionsButtonUpdate.Response) {
        self.viewController?.displayDiscussionsButtonUpdate(
            viewModel: .init(
                title: self.makeDiscussionsButtonTitle(step: response.step),
                isEnabled: response.step.discussionProxyID != nil
            )
        )
    }

    func presentSolutionsButtonUpdate(response: StepDataFlow.SolutionsButtonUpdate.Response) {
        func displayHideSolutionsButtonUpdate() {
            self.viewController?.displaySolutionsButtonUpdate(viewModel: .init(title: nil, isEnabled: false))
        }

        switch response.result {
        case .success(let discussionThread):
            guard let discussionThread = discussionThread,
                  discussionThread.threadType == .solutions,
                  !discussionThread.discussionProxy.isEmpty else {
                return displayHideSolutionsButtonUpdate()
            }

            self.viewController?.displaySolutionsButtonUpdate(
                viewModel: .init(
                    title: self.makeSolutionsButtonTitle(discussionThread: discussionThread),
                    isEnabled: true
                )
            )
        case .failure:
            displayHideSolutionsButtonUpdate()
        }
    }

    func presentDiscussions(response: StepDataFlow.DiscussionsPresentation.Response) {
        guard let discussionProxyID = response.step.discussionProxyID else {
            return
        }

        self.viewController?.displayDiscussions(
            viewModel: .init(
                discussionProxyID: discussionProxyID,
                stepID: response.step.id,
                shouldEmbedInWriteComment: (response.step.discussionsCount ?? 0) == 0
            )
        )
    }

    func presentSolutions(response: StepDataFlow.SolutionsPresentation.Response) {
        guard response.discussionThread.threadType == .solutions,
              !response.discussionThread.discussionProxy.isEmpty else {
            return
        }

        self.viewController?.displaySolutions(
            viewModel: .init(
                stepID: response.step.id,
                discussionProxyID: response.discussionThread.discussionProxy,
                shouldEmbedInWriteComment: response.discussionThread.discussionsCount == 0
            )
        )
    }

    func presentWaitingState(response: StepDataFlow.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    // MARK: Private API

    private func makeViewModel(
        step: Step,
        fontSize: StepFontSize,
        storedImages: [StepDataFlow.StoredImage]
    ) -> Guarantee<StepViewModel> {
        Guarantee { seal in
            let contentType: StepViewModel.ContentType = {
                switch step.block.type {
                case .video:
                    if let video = step.block.video {
                        let viewModel = StepVideoViewModel(
                            video: video,
                            videoThumbnailImageURL: URL(string: video.thumbnailURL)
                        )
                        return .video(viewModel: viewModel)
                    }
                    return .video(viewModel: nil)
                default:
                    let htmlString = self.makeProcessedContentHTMLString(
                        step.block.text ?? "",
                        fontSize: fontSize,
                        storedImages: storedImages
                    )
                    return .text(htmlString: htmlString)
                }
            }()

            let quizType: StepDataFlow.QuizType?
            switch step.block.type {
            case .text, .video:
                quizType = nil
            default:
                quizType = StepDataFlow.QuizType(blockName: step.block.name)
            }

            let shouldShowStepStatistics: Bool = {
                if quizType == nil {
                    return false
                }
                if case .unknown = quizType {
                    return false
                }
                return true
            }()

            let discussionsLabelTitle = self.makeDiscussionsButtonTitle(step: step)
            let urlPath = "\(StepikApplicationsInfo.stepikURL)/lesson/\(step.lessonID)/step/\(step.position)?from_mobile_app=true"

            let viewModel = StepViewModel(
                content: contentType,
                quizType: quizType,
                discussionsLabelTitle: discussionsLabelTitle,
                isDiscussionsEnabled: step.discussionProxyID != nil,
                discussionProxyID: step.discussionProxyID,
                stepURLPath: urlPath,
                lessonID: step.lessonID,
                passedByCount: shouldShowStepStatistics ? step.passedByCount : nil,
                correctRatio: shouldShowStepStatistics ? step.correctRatio : nil,
                step: step
            )

            seal(viewModel)
        }
    }

    private func makeDiscussionsButtonTitle(step: Step) -> String {
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

    private func makeSolutionsButtonTitle(discussionThread: DiscussionThread) -> String {
        if discussionThread.discussionsCount > 0 {
            return String(
                format: NSLocalizedString("SolutionsButtonTitle", comment: ""),
                arguments: [
                    FormatterHelper.longNumber(discussionThread.discussionsCount)
                ]
            )
        }

        return NSLocalizedString("NoSolutionsButtonTitle", comment: "")
    }

    private func makeProcessedContentHTMLString(
        _ text: String,
        fontSize: StepFontSize,
        storedImages: [StepDataFlow.StoredImage]
    ) -> String {
        let base64EncodedStringByImageURL = Dictionary(
            uniqueKeysWithValues: storedImages.map { ($0.url, $0.data.base64EncodedString()) }
        )

        var contentProcessingRules = ContentProcessor.defaultRules

        if !base64EncodedStringByImageURL.isEmpty {
            contentProcessingRules.append(
                ReplaceImageSourceWithBase64(
                    base64EncodedStringByImageURL: base64EncodedStringByImageURL,
                    extractorType: HTMLExtractor.self
                )
            )
        }

        if text.contains("<model-viewer") {
            contentProcessingRules.append(ReplaceModelViewerWithARImageRule(extractorType: HTMLExtractor.self))
        }

        let contentProcessingInjections = ContentProcessor.defaultInjections + [FontSizeInjection(fontSize: fontSize)]

        let contentProcessor = ContentProcessor(
            content: text,
            rules: contentProcessingRules,
            injections: contentProcessingInjections
        )

        return contentProcessor.processContent()
    }
}
