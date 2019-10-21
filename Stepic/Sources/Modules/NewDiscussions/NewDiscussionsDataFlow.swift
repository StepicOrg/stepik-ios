import Foundation

enum NewDiscussions {
    // MARK: Common structs

    struct DiscussionsResult {
        let discussions: [NewDiscussionsDiscussionViewModel]
        let discussionsLeftToLoad: Int
    }

    struct DiscussionsData {
        let discussionProxy: DiscussionProxy
        let discussions: [Comment]
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
