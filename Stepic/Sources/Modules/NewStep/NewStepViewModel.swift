import Foundation

struct NewStepViewModel {
    let content: ContentType
    let quizType: NewStep.QuizType?
    let discussionsLabelTitle: String
    let discussionProxyID: DiscussionProxy.IdType?
    let stepURLPath: String

    @available(*, deprecated, message: "Deprecated initialization")
    let step: Step

    enum ContentType {
        case text(htmlString: String)
        case video(viewModel: NewStepVideoViewModel?)
    }
}

struct NewStepVideoViewModel {
    @available(*, deprecated, message: "Deprecated initialization")
    let video: Video
    let videoThumbnailImageURL: URL?
}
