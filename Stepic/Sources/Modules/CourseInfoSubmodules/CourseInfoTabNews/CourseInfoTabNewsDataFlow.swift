import Foundation

enum CourseInfoTabNews {
    /// Show news
    enum NewsLoad {
        struct Request {}

        struct Data {
            let course: Course
            let announcements: [AnnouncementPlainObject]
            let hasNextPage: Bool
        }

        struct Response {
            let result: StepikResult<Data>
        }

        struct ViewModel {}
    }
}
