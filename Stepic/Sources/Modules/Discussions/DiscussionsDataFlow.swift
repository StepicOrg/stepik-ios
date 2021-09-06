import Foundation

enum Discussions {
    // MARK: - Common types -

    enum PresentationContext {
        case fromBeginning
        case scrollTo(discussionID: Comment.IdType, replyID: Comment.IdType?)
    }

    /// Interactor -> presenter
    struct ResponseData {
        let discussionProxy: DiscussionProxy
        let discussions: [Comment]
        let discussionsIDsFetchingMore: Set<Comment.IdType>
        let replies: [Comment.IdType: [Comment]]
        let currentSortType: SortType
        let discussionsLeftToLoadInLeftHalf: Int
        let discussionsLeftToLoadInRightHalf: Int
        let selectedCommentID: Comment.IdType?
    }

    /// Presenter -> ViewController
    struct ViewData {
        let discussions: [DiscussionsDiscussionViewModel]
        let hasPreviousPage: Bool
        let hasNextPage: Bool
    }

    enum SortType: String, CaseIterable {
        case last
        case mostLiked
        case mostActive
        case recentActivity
    }

    // MARK: - Use cases -

    /// Update navigation title and buttons
    enum NavigationItemUpdate {
        struct Response {
            let threadType: DiscussionThread.ThreadType
        }

        struct ViewModel {
            let title: String
            let shouldShowSortButton: Bool
            let shouldShowComposeButton: Bool
            let threadType: DiscussionThread.ThreadType
        }
    }

    // MARK: Fetch comments

    /// Show discussions
    enum DiscussionsLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<ResponseData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next part discussions
    enum NextDiscussionsLoad {
        struct Request {
            let direction: PaginationDirection
        }

        struct Response {
            let result: StepikResult<ResponseData>
            let direction: PaginationDirection
        }

        struct ViewModel {
            let state: PaginationState
            let direction: PaginationDirection
        }
    }

    /// Load next part discussions
    enum NextRepliesLoad {
        struct Request {
            let discussionID: Comment.IdType
        }

        struct Response {
            let result: ResponseData
        }

        struct ViewModel {
            let data: ViewData
        }
    }

    // MARK: - Comment actions

    /// Scrolls to comment
    enum SelectComment {
        struct Response {
            let commentID: Comment.IdType
        }

        struct ViewModel {
            let commentID: Comment.IdType
        }
    }

    /// Present write course review (after compose bar button item click)
    enum WriteCommentPresentation {
        enum PresentationContext {
            case create
            case edit
        }

        struct Request {
            let commentID: Comment.IdType?
            let presentationContext: PresentationContext
        }

        struct Response {
            let targetID: Int
            let parentID: Comment.IdType?
            let comment: Comment?
            let discussionThreadType: DiscussionThread.ThreadType
        }

        struct ViewModel {
            let targetID: Int
            let parentID: Comment.IdType?
            let comment: Comment?
            let discussionThreadType: DiscussionThread.ThreadType
        }
    }

    /// Show newly created comment
    enum CommentCreated {
        struct Response {
            let result: ResponseData
        }

        struct ViewModel {
            let data: ViewData
        }
    }

    /// Show updated comment
    enum CommentUpdated {
        struct Response {
            let result: ResponseData
        }

        struct ViewModel {
            let data: ViewData
        }
    }

    /// Deletes comment by id
    enum CommentDelete {
        struct Request {
            let commentID: Comment.IdType
        }

        struct Response {
            let result: StepikResult<ResponseData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Updates comment's vote value to epic or null
    enum CommentLike {
        struct Request {
            let commentID: Comment.IdType
        }

        struct Response {
            let result: ResponseData
        }

        struct ViewModel {
            let data: ViewData
        }
    }

    /// Updates comment's vote value to abuse or null
    enum CommentAbuse {
        struct Request {
            let commentID: Comment.IdType
        }

        struct Response {
            let result: ResponseData
        }

        struct ViewModel {
            let data: ViewData
        }
    }

    /// Present solution (submission)
    enum SolutionPresentation {
        struct Request {
            let commentID: Comment.IdType
        }

        struct Response {
            let stepID: Step.IdType
            let submission: Submission
            let discussionID: Comment.IdType
        }

        struct ViewModel {
            let stepID: Step.IdType
            let submission: Submission
            let discussionID: Comment.IdType
        }
    }

    /// Show comment actions
    enum CommentActionSheetPresentation {
        struct Request {
            let commentID: Comment.IdType
        }

        struct Response {
            let stepID: Step.IdType
            let isTeacher: Bool
            let isTheoryStep: Bool
            let comment: Comment
        }

        struct ViewModel {
            let stepID: Step.IdType
            let isTeacher: Bool
            let isTheoryStep: Bool
            let comment: DiscussionsCommentViewModel
        }
    }

    // MARK: - Sort type

    /// Presents action sheet with available and current sort type (after sort type bar button item click)
    enum SortTypesPresentation {
        struct Request {}

        struct Response {
            let currentSortType: SortType
            let availableSortTypes: [SortType]
        }

        struct ViewModel {
            let title: String
            let items: [Item]

            struct Item {
                let uniqueIdentifier: UniqueIdentifierType
                let title: String
            }
        }
    }

    /// Updates current sort type
    enum SortTypeUpdate {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let result: ResponseData
        }

        struct ViewModel {
            let data: ViewData
        }
    }

    // MARK: - HUD

    /// Handle HUD
    enum BlockingWaitingIndicatorUpdate {
        struct Response {
            let shouldDismiss: Bool
        }

        struct ViewModel {
            let shouldDismiss: Bool
        }
    }

    // MARK: - States -

    enum ViewControllerState {
        case loading
        case error
        case result(data: ViewData)
    }

    enum PaginationDirection {
        case top
        case bottom
    }

    enum PaginationState {
        case result(data: ViewData)
        case error
    }
}
