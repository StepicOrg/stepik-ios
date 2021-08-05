import Foundation

struct StepViewModel {
    let content: ContentType
    let quizType: StepDataFlow.QuizType?
    let discussionsLabelTitle: String
    let isDiscussionsEnabled: Bool
    let discussionProxyID: DiscussionProxy.IdType?
    let stepURLPath: String
    let lessonID: Lesson.IdType
    let passedByCount: Int?
    let correctRatio: Float?

    let hasReview: Bool
    let instructionType: InstructionType?

    @available(*, deprecated, message: "Deprecated initialization")
    let step: Step

    enum ContentType {
        case text(processedContent: ProcessedContent)
        case video(viewModel: StepVideoViewModel?)
    }
}

struct StepVideoViewModel {
    @available(*, deprecated, message: "Deprecated initialization")
    let video: Video
    let videoThumbnailImageURL: URL?
}

struct DisabledStepViewModel {
    let step: StepViewModel
    let disabled: DisabledViewModel

    struct DisabledViewModel {
        let title: String
        let message: String
        let isTeacher: Bool
    }
}
