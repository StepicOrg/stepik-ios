import Foundation

enum CourseInfoTabNews {
    // MARK: Common structs

    /// Response data
    struct NewsResponseData {
        let course: Course
        let currentUser: User?
        let announcements: [AnnouncementPlainObject]
        let hasNextPage: Bool
    }

    /// ViewModel data
    struct NewsResultData {
        let news: [CourseInfoTabNewsViewModel]
        let hasNextPage: Bool
    }

    // MARK: Use Cases

    /// Show news
    enum NewsLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<NewsResponseData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next part reviews
    enum NextNewsLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<NewsResponseData>
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: NewsResultData)
    }

    enum PaginationState {
        case error
        case result(data: NewsResultData)
    }
}
