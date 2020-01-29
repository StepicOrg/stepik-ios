import PromiseKit
import UIKit

protocol StepPresenterProtocol {
    func presentStep(response: StepDataFlow.StepLoad.Response)
    func presentStepTextUpdate(response: StepDataFlow.StepTextUpdate.Response)
    func presentPlayStep(response: StepDataFlow.PlayStep.Response)
    func presentControlsUpdate(response: StepDataFlow.ControlsUpdate.Response)
    func presentDiscussionsButtonUpdate(response: StepDataFlow.DiscussionsButtonUpdate.Response)
    func presentDiscussions(response: StepDataFlow.DiscussionsPresentation.Response)
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
                title: self.makeDiscussionsLabelTitle(step: response.step),
                isEnabled: response.step.discussionProxyID != nil
            )
        )
    }

    func presentDiscussions(response: StepDataFlow.DiscussionsPresentation.Response) {
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

            let discussionsLabelTitle = self.makeDiscussionsLabelTitle(step: step)
            let urlPath = "\(StepicApplicationsInfo.stepicURL)/lesson/\(step.lessonID)/step/\(step.position)?from_mobile_app=true"

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

    private func makeProcessedContentHTMLString(
        _ text: String,
        fontSize: StepFontSize,
        storedImages: [StepDataFlow.StoredImage]
    ) -> String {
        let base64EncodedStringByImageURL = Dictionary(
            uniqueKeysWithValues: storedImages.map { ($0.url, $0.data.base64EncodedString()) }
        )

        var rules = ContentProcessor.defaultRules

        if !base64EncodedStringByImageURL.isEmpty {
            rules.append(
                ReplaceImageSourceWithBase64(
                    base64EncodedStringByImageURL: base64EncodedStringByImageURL,
                    extractorType: HTMLExtractor.self
                )
            )
        }

        let injections = ContentProcessor.defaultInjections + [FontSizeInjection(fontSize: fontSize)]

        let contentProcessor = ContentProcessor(
            content: text,
            rules: rules,
            injections: injections
        )

        return contentProcessor.processContent()
    }
}
