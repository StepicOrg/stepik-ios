import Foundation

enum WriteComment {
    // MARK: Common types

    /// By backend architecture it's could be any object, but for now, only steps allowed.
    /// `target` == `step_id`.
    typealias TargetIDType = Step.IdType
    typealias ParentIDtype = Comment.IdType

    enum PresentationContext {
        case create
        case edit
    }

    struct CommentInfo {
        let text: String
        let presentationContext: PresentationContext
    }

    // MARK: - Use cases -

    /// Show comment
    enum CommentLoad {
        struct Request { }

        struct Response {
            let data: CommentInfo
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Handle review text change
    enum CommentTextUpdate {
        struct Request {
            let text: String
        }

        struct Response {
            let data: CommentInfo
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: WriteCommentViewModel)
    }
}
