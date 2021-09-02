import Foundation

enum CourseSearch {
    enum CourseContentLoad {
        struct Request {}

        struct Response {
            struct Data {
                let course: Course
                let searchQueryResults: [SearchQueryResult]
            }

            let result: StepikResult<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    enum Search {
        struct Request {
            let query: String
        }

        struct Response {}

        struct ViewModel {}
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case searching
        case error(ErrorDomain)
        case result(data: CourseSearchViewModel)

        enum ErrorDomain {
            case content
            case search
        }
    }
}
