import Foundation

enum NewDiscussions {
    // MARK: Common types

    struct DiscussionsResult {
        let discussions: [NewDiscussionsDiscussionViewModel]
        let discussionsLeftToLoad: Int
    }

    struct DiscussionsData {
        let discussionProxy: DiscussionProxy
        let discussions: [Comment]
        let discussionsIDsFetchingMore: Set<Comment.IdType>
        let replies: [Comment.IdType: [Comment]]
        let sortType: SortType
    }

    enum SortType {
        case last
        case mostLiked
        case mostActive
        case recentActivity

        var title: String {
            switch self {
            case .last:
                return NSLocalizedString("DiscussionsSortTypeLastDiscussions", comment: "")
            case .mostLiked:
                return NSLocalizedString("DiscussionsSortTypeMostLikedDiscussions", comment: "")
            case .mostActive:
                return NSLocalizedString("DiscussionsSortTypeMostActiveDiscussions", comment: "")
            case .recentActivity:
                return NSLocalizedString("DiscussionsSortTypeRecentActivityDiscussions", comment: "")
            }
        }

        static var `default`: SortType {
            return .last
        }
    }

    // MARK: - Use cases -

    /// Show discussions
    enum DiscussionsLoad {
        struct Request { }

        struct Response {
            let result: Result<DiscussionsData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next part discussions
    enum NextDiscussionsLoad {
        struct Request { }

        struct Response {
            let result: Result<DiscussionsData>
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
            let result: DiscussionsData
        }

        struct ViewModel {
            let data: DiscussionsResult
        }
    }

    /// Present write course review (after compose bar button item click)
    enum WriteCommentPresentation {
        struct Request {
            let commentID: Comment.IdType?
        }

        struct Response {
            let targetID: Int
            let parentID: Comment.IdType?
        }

        struct ViewModel {
            let targetID: Int
            let parentID: Comment.IdType?
        }
    }

    /// Show current user newly created comment
    enum CommentCreated {
        struct Request {
            let comment: Comment
        }

        struct Response {
            let result: DiscussionsData
        }

        struct ViewModel {
            let data: DiscussionsResult
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
        case result(data: DiscussionsResult)
    }

    enum PaginationState {
        case result(data: DiscussionsResult)
        case error
    }
}
