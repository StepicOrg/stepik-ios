import Foundation

enum NewProfileCreatedCourses {
    /// Show courses
    enum CoursesLoad {
        struct Request {}

        struct Response {
            let teacherID: User.IdType
        }

        struct ViewModel {
            let teacherID: User.IdType
        }
    }

    /// Try to set online status
    enum OnlineModeReset {
        struct Request {
            let module: CourseListInputProtocol
        }
    }
}
