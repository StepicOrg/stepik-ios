import PromiseKit
import UIKit

protocol NewStepPresenterProtocol {
    func presentStep(response: NewStep.StepLoad.Response)
    func presentStepTextUpdate(response: NewStep.StepTextUpdate.Response)
    func presentPlayStep(response: NewStep.PlayStep.Response)
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
                fontSize: data.fontSize,
                storedImages: data.storedImages
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
            fontSize: response.fontSize,
            storedImages: []
        )

        self.viewController?.displayStepTextUpdate(viewModel: .init(htmlText: htmlString))
    }

    func presentPlayStep(response: NewStep.PlayStep.Response) {
        self.viewController?.displayPlayStep(viewModel: .init())
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

    private func makeViewModel(
        step: Step,
        fontSize: StepFontSize,
        storedImages: [NewStep.StoredImage]
    ) -> Guarantee<NewStepViewModel> {
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
                        fontSize: fontSize,
                        storedImages: storedImages
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

            let viewModel = NewStepViewModel(
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
        storedImages: [NewStep.StoredImage]
    ) -> String {
        let base64EncodedStringByImageURL = Dictionary(
            uniqueKeysWithValues: storedImages.compactMap { storedImage -> (URL, String)? in
                guard let data = storedImage.storedImageFile.data,
                      let image = UIImage(data: data),
                      let jpegData = image.jpegData(compressionQuality: 1.0) else {
                    return nil
                }
                return (storedImage.originalURL, jpegData.base64EncodedString())
            }
        )

        let rules = ContentProcessor.defaultRules + [
            ReplaceImageSourceWithLocalBase64(
                base64EncodedStringByImageURL: base64EncodedStringByImageURL,
                extractorType: HTMLExtractor.self
            )
        ]

        let contentProcessor = ContentProcessor(
            content: text,
            rules: rules,
            injections: ContentProcessor.defaultInjections + [FontSizeInjection(fontSize: fontSize)]
        )

        return contentProcessor.processContent()
    }
}
