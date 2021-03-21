import PromiseKit
import UIKit

protocol StepPresenterProtocol {
    func presentStep(response: StepDataFlow.StepLoad.Response)
    func presentStepTextUpdate(response: StepDataFlow.StepTextUpdate.Response)
    func presentStepAutoplay(response: StepDataFlow.PlayStep.Response)
    func presentControlsUpdate(response: StepDataFlow.ControlsUpdate.Response)
    func presentDiscussionsButtonUpdate(response: StepDataFlow.DiscussionsButtonUpdate.Response)
    func presentSolutionsButtonUpdate(response: StepDataFlow.SolutionsButtonUpdate.Response)
    func presentDiscussions(response: StepDataFlow.DiscussionsPresentation.Response)
    func presentSolutions(response: StepDataFlow.SolutionsPresentation.Response)
    func presentDownloadARQuickLook(response: StepDataFlow.DownloadARQuickLookPresentation.Response)
    func presentARQuickLook(response: StepDataFlow.ARQuickLookPresentation.Response)
    func presentURL(response: StepDataFlow.URLPresentation.Response)
    func presentWaitingState(response: StepDataFlow.BlockingWaitingIndicatorUpdate.Response)
}

final class StepPresenter: StepPresenterProtocol {
    weak var viewController: StepViewControllerProtocol?

    private let urlFactory: StepikURLFactory

    init(urlFactory: StepikURLFactory) {
        self.urlFactory = urlFactory
    }

    func presentStep(response: StepDataFlow.StepLoad.Response) {
        switch response.result {
        case .success(let data):
            if !data.step.isEnabled && data.isDisabledStepsSupported {
                let viewModel = self.makeDisabledStepViewModel(
                    step: data.step,
                    stepFontSize: data.stepFontSize,
                    storedImages: data.storedImages
                )

                self.viewController?.displayStep(viewModel: .init(state: .disabled(data: viewModel)))
            } else {
                let viewModel = self.makeStepViewModel(
                    step: data.step,
                    stepFontSize: data.stepFontSize,
                    storedImages: data.storedImages
                )

                self.viewController?.displayStep(viewModel: .init(state: .result(data: viewModel)))
            }
        case .failure:
            self.viewController?.displayStep(viewModel: .init(state: .error))
        }
    }

    func presentStepTextUpdate(response: StepDataFlow.StepTextUpdate.Response) {
        let processedContent = self.makeProcessedContent(
            response.text,
            stepFontSize: response.fontSize,
            storedImages: response.storedImages
        )
        self.viewController?.displayStepTextUpdate(viewModel: .init(processedContent: processedContent))
    }

    func presentStepAutoplay(response: StepDataFlow.PlayStep.Response) {
        self.viewController?.displayStepAutoplay(viewModel: .init())
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
                isTeacher: response.isTeacher,
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
                isTeacher: response.isTeacher,
                shouldEmbedInWriteComment: response.discussionThread.discussionsCount == 0
            )
        )
    }

    func presentDownloadARQuickLook(response: StepDataFlow.DownloadARQuickLookPresentation.Response) {
        self.viewController?.displayDownloadARQuickLook(viewModel: .init(url: response.url))
    }

    func presentARQuickLook(response: StepDataFlow.ARQuickLookPresentation.Response) {
        switch response.result {
        case .success(let storedURL):
            let validPath = storedURL
                .absoluteString
                .replacingOccurrences(of: "file://", with: "")
            let fileURL = URL(fileURLWithPath: validPath)

            self.viewController?.displayARQuickLook(viewModel: .init(localURL: fileURL))
        case .failure(let error):
            let title: String
            let message: String

            if case StepInteractor.Error.arQuickLookUnsupported = error {
                title = NSLocalizedString("StepARQuickLookUnsupportedAlertTitle", comment: "")
                message = NSLocalizedString("StepARQuickLookUnsupportedAlertMessage", comment: "")
            } else {
                title = NSLocalizedString("Error", comment: "")
                message = NSLocalizedString("DownloadARQuickLookAlertFailedMessage", comment: "")
            }

            self.viewController?.displayOKAlert(viewModel: .init(title: title, message: message))
        }
    }

    func presentURL(response: StepDataFlow.URLPresentation.Response) {
        self.viewController?.displayURL(viewModel: .init(url: response.url))
    }

    func presentWaitingState(response: StepDataFlow.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    // MARK: Private API

    private func makeDisabledStepViewModel(
        step: Step,
        stepFontSize: StepFontSize,
        storedImages: [StepDataFlow.StoredImage]
    ) -> DisabledStepViewModel {
        let stepViewModel = self.makeStepViewModel(
            step: step,
            stepFontSize: stepFontSize,
            storedImages: storedImages
        )

        let title: String
        let message: String
        let isTeacher = step.lesson?.canEdit ?? false

        if isTeacher {
            title = NSLocalizedString("StepDisabledTeacherTitle", comment: "")

            let isStepInCourse = step.lesson?.unit != nil
            if isStepInCourse {
                message = String(
                    format: NSLocalizedString("StepDisabledTeacherInCourseMessage", comment: ""),
                    arguments: [
                        self.makeNeedsPlanTitle(
                            step.needsPlanType,
                            proLocalizedKey: "StepDisabledTeacherInCoursePlanProTitle",
                            enterpriseLocalizedKey: "StepDisabledTeacherInCoursePlanEnterpriseTitle"
                        )
                    ]
                )
            } else {
                message = String(
                    format: NSLocalizedString("StepDisabledTeacherNoCourseMessage", comment: ""),
                    arguments: [
                        self.makeNeedsPlanTitle(
                            step.needsPlanType,
                            proLocalizedKey: "StepDisabledTeacherNoCoursePlanProTitle",
                            enterpriseLocalizedKey: "StepDisabledTeacherNoCoursePlanEnterpriseTitle"
                        )
                    ]
                )
            }
        } else {
            title = NSLocalizedString("StepDisabledStudentTitle", comment: "")

            let stepHyperlink: String = {
                let stepURLString = self.urlFactory.makeStep(
                    lessonID: step.lessonID,
                    stepPosition: step.position
                )?.absoluteString ?? ""

                let lessonTitle = step.lesson != nil
                    ? FormatterHelper.lessonTitle(step.lesson.require())
                    : ""

                let stepTitle = String(
                    format: NSLocalizedString("StepPosition", comment: ""),
                    arguments: ["\(step.position)"]
                )

                return "<a href=\"\(stepURLString)\">\(lessonTitle) → \(stepTitle)</a>"
            }()
            message = String(
                format: NSLocalizedString("StepDisabledStudentMessage", comment: ""),
                arguments: [stepHyperlink]
            )
        }

        return DisabledStepViewModel(
            step: stepViewModel,
            disabled: .init(
                title: title,
                message: message,
                isTeacher: isTeacher
            )
        )
    }

    private func makeNeedsPlanTitle(
        _ needsPlanType: CourseType?,
        proLocalizedKey: String,
        enterpriseLocalizedKey: String
    ) -> String {
        switch needsPlanType {
        case .pro:
            return NSLocalizedString(proLocalizedKey, comment: "")
        case .enterprise:
            return NSLocalizedString(enterpriseLocalizedKey, comment: "")
        default:
            return "N/A"
        }
    }

    private func makeStepViewModel(
        step: Step,
        stepFontSize: StepFontSize,
        storedImages: [StepDataFlow.StoredImage]
    ) -> StepViewModel {
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
                let processedContent = self.makeProcessedContent(
                    step.block.text ?? "",
                    stepFontSize: stepFontSize,
                    storedImages: storedImages
                )
                return .text(processedContent: processedContent)
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
        let stepURLPath = self.urlFactory.makeStep(
            lessonID: step.lessonID,
            stepPosition: step.position,
            fromMobile: true
        )?.absoluteString ?? ""

        let viewModel = StepViewModel(
            content: contentType,
            quizType: quizType,
            discussionsLabelTitle: discussionsLabelTitle,
            isDiscussionsEnabled: step.discussionProxyID != nil,
            discussionProxyID: step.discussionProxyID,
            stepURLPath: stepURLPath,
            lessonID: step.lessonID,
            passedByCount: shouldShowStepStatistics ? step.passedByCount : nil,
            correctRatio: shouldShowStepStatistics ? step.correctRatio : nil,
            step: step
        )

        return viewModel
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

    private func makeProcessedContent(
        _ text: String,
        stepFontSize: StepFontSize,
        storedImages: [StepDataFlow.StoredImage]
    ) -> ProcessedContent {
        // TODO: Force to use HTML processing explicitly.
        let text = "<div>\(text)</div>"

        let base64EncodedStringByImageURL = Dictionary(
            uniqueKeysWithValues: storedImages.map { ($0.url, $0.data.base64EncodedString()) }
        )

        var contentProcessingRules = ContentProcessor.defaultRules

        if !base64EncodedStringByImageURL.isEmpty {
            contentProcessingRules.append(
                ReplaceImageSourceWithBase64Rule(
                    base64EncodedStringByImageURL: base64EncodedStringByImageURL,
                    extractorType: HTMLExtractor.self
                )
            )
        }

        let shouldDisplayARThumbnails = text.contains("<model-viewer") && RemoteConfig.shared.isARQuickLookAvailable
        if shouldDisplayARThumbnails {
            contentProcessingRules.append(ReplaceModelViewerWithARImageRule(extractorType: HTMLExtractor.self))
        }

        let contentProcessingInjections = ContentProcessor.defaultInjections + [
            FontSizeInjection(stepFontSize: stepFontSize),
            TextColorInjection(dynamicColor: .stepikPrimaryText)
        ]

        let contentProcessor = ContentProcessor(
            rules: contentProcessingRules,
            injections: contentProcessingInjections
        )
        let processedContent = contentProcessor.processContent(text)

        return .html(processedContent.stringValue)
    }
}
