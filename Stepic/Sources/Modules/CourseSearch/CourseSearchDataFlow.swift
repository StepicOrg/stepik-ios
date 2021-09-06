import Foundation

enum CourseSearch {
    // MARK: Common

    struct SearchResponseData {
        let course: Course?
        let searchResults: [SearchResultPlainObject]
        let hasNextPage: Bool
    }

    struct SearchResultData {
        let searchResults: [CourseSearchResultViewModel]
        let hasNextPage: Bool
    }

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

    /// Handle query update and filter suggestions
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
    enum SearchResultsLoad {
        struct Request {
            let source: Source

            enum Source {
                case searchQuery
                case suggestion(UniqueIdentifierType)
            }
        }

        struct Response {
            let result: StepikResult<SearchResponseData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next page
    enum NextSearchResultsLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<SearchResponseData>
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    /// Show comment user profile
    enum CommentUserPresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let userID: User.IdType
        }

        struct ViewModel {
            let userID: User.IdType
        }
    }

    /// Present discussions thread
    enum CommentDiscussionPresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let searchResult: SearchResultPlainObject
        }

        struct ViewModel {
            let discussionProxyID: DiscussionProxy.IdType
            let stepID: Step.IdType
            let isTeacher: Bool
            let presentationContext: Discussions.PresentationContext
        }
    }

    /// Resolve SearchResult -> LessonPresentation
    enum SearchResultPresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Show lesson
    enum LessonPresentation {
        struct Response {
            let lessonID: Lesson.IdType
            let stepID: Step.IdType?
        }

        struct ViewModel {
            let lessonID: Lesson.IdType
            let stepID: Step.IdType?
        }
    }

    enum LoadingStatePresentation {
        struct Response {}

        struct ViewModel {}
    }

    // MARK: States

    enum ViewControllerState {
        case idle
        case loading
        case error
        case result(data: SearchResultData)
    }

    enum PaginationState {
        case error
        case result(data: SearchResultData)
    }
}
