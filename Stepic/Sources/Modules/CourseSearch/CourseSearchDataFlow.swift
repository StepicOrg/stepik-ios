import Foundation

enum CourseSearch {
    /// Load course & initial suggestions
    enum CourseSearchLoad {
        struct Request {}

        struct Response {
            struct Data {
                let course: Course?
                let suggestions: [SearchQueryResult]
            }

            let result: StepikResult<Data>
        }

        struct ViewModel {
            let placeholderText: String
            let suggestions: [CourseSearchSuggestionViewModel]
        }
    }

    /// Load suggestions
    enum CourseSearchSuggestionsLoad {
        struct Request {}

        struct Response {
            let suggestions: [SearchQueryResult]
        }

        struct ViewModel {
            let suggestions: [CourseSearchSuggestionViewModel]
        }
    }

    /// Filter suggestions
    enum SearchQueryUpdate {
        struct Request {
            let query: String
        }

        struct Response {
            let query: String
            let suggestions: [SearchQueryResult]
        }

        struct ViewModel {
            let query: String
            let suggestions: [CourseSearchSuggestionViewModel]
        }
    }

    /// Perform search in course
    enum Search {
        struct Request {
            let source: Source

            enum Source {
                case searchQuery
                case suggestion(UniqueIdentifierType)
            }
        }

        struct Response {}

        struct ViewModel {}
    }

    // MARK: States

    enum ViewControllerState {
        case idle
        case loading
        case error
        case result(data: CourseSearchViewModel)
    }
}
