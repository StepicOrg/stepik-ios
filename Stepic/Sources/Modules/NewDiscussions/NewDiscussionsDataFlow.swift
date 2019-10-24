import Foundation

enum NewDiscussions {
    // MARK: Common types

    /// Presenter -> ViewController
    struct DiscussionsViewData {
        let discussions: [NewDiscussionsDiscussionViewModel]
        let discussionsLeftToLoad: Int
    }

    /// Interactor -> presenter
    struct DiscussionsResponseData {
        let discussionProxy: DiscussionProxy
        let discussions: [Comment]
        let discussionsIDsFetchingMore: Set<Comment.IdType>
        let replies: [Comment.IdType: [Comment]]
        let currentSortType: SortType
    }

    enum SortType: String, CaseIterable {
        case last
        case mostLiked
        case mostActive
        case recentActivity

        static var `default`: SortType {
            return .last
        }
    }

    // MARK: - Use cases -

    /// Show discussions
    enum DiscussionsLoad {
        struct Request { }

        struct Response {
            let result: Result<DiscussionsResponseData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next part discussions
    enum NextDiscussionsLoad {
        struct Request { }

        struct Response {
            let result: Result<DiscussionsResponseData>
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    /// Load next part discussions
    enum NextRepliesLoad {
        struct Request {
            let discussionID: Comment.IdType
        }

        struct Response {
            let result: DiscussionsResponseData
        }

        struct ViewModel {
            let data: DiscussionsViewData
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
            let presentationContext: PresentationContext
        }

        struct ViewModel {
            let targetID: Int
            let parentID: Comment.IdType?
            let presentationContext: WriteComment.PresentationContext
        }
    }

    /// Show newly created comment
    enum CommentCreated {
        struct Response {
            let result: DiscussionsResponseData
        }

        struct ViewModel {
            let data: DiscussionsViewData
        }
    }

    /// Show updated comment
    enum CommentUpdated {
        struct Response {
            let result: DiscussionsResponseData
        }

        struct ViewModel {
            let data: DiscussionsViewData
        }
    }

    /// Deletes comment by id
    enum CommentDelete {
        struct Request {
            let commentID: Comment.IdType
        }

        struct Response {
            let result: Result<DiscussionsResponseData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Presents sort action sheet (after sort type bar button item click)
    enum SortTypePresentation {
        struct Request { }

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
            let result: DiscussionsResponseData
        }

        struct ViewModel {
            let data: DiscussionsViewData
        }
    }

    /// Handle HUD
    enum BlockingWaitingIndicatorUpdate {
        struct Response {
            let shouldDismiss: Bool
        }

        struct ViewModel {
            let shouldDismiss: Bool
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: DiscussionsViewData)
    }

    enum PaginationState {
        case result(data: DiscussionsViewData)
        case error
    }
}
