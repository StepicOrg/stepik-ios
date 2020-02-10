import Foundation

enum WriteComment {
    // MARK: Common types

    /// By backend architecture it's could be any object, but for now, only steps allowed.
    /// `target` == `step_id`.
    typealias TargetIDType = Step.IdType
    typealias ParentIDType = Comment.IdType

    struct CommentData {
        let text: String
        let comment: Comment?
        let submission: Submission?
        let discussionThreadType: DiscussionThread.ThreadType
    }

    // MARK: - Use cases -

    /// Update navigation item (for now only title)
    enum NavigationItemUpdate {
        struct Response {
            let discussionThreadType: DiscussionThread.ThreadType
        }

        struct ViewModel {
            let title: String
        }
    }

    /// Show comment
    enum CommentLoad {
        struct Request {}

        struct Response {
            let data: CommentData
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
            let data: CommentData
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Do comment main action (create or update)
    enum CommentMainAction {
        struct Request {}

        struct Response {
            let data: Result<CommentData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Shows alert about changes losing
    enum CommentCancelPresentation {
        struct Request {}

        struct Response {
            let originalText: String
            let currentText: String
            let originalSubmissionID: Submission.IdType?
            let currentSubmissionID: Submission.IdType?
        }

        struct ViewModel {
            let shouldAskUser: Bool
        }
    }

    /// Show or select solution
    enum SolutionPresentation {
        struct Request {}

        struct Response {
            let stepID: Step.IdType
        }

        struct ViewModel {
            let stepID: Step.IdType
        }
    }

    /// Handle solution update.
    enum SolutionUpdate {
        struct Request {
            let submission: Submission
        }

        struct Response {
            let data: CommentData
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
