import UIKit

enum Explore {
    // MARK: Submodules identifiers

    enum Submodule: String, UniqueIdentifiable {
        case languageSwitch
        case catalogBlocks
        case visitedCourses

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }
    }

    // MARK: Use cases

    /// Content refresh
    enum ContentLoad {
        struct Request {}

        struct Response {
            let contentLanguage: ContentLanguage
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Check for language switch visibility
    enum LanguageSwitchAvailabilityCheck {
        struct Request {}

        struct Response {
            let isHidden: Bool
        }

        struct ViewModel {
            let isHidden: Bool
        }
    }

    // Refresh course block
    enum CourseListStateUpdate {
        enum State {
            case empty
            case error
        }

        struct Response {
            let module: Submodule
            let result: State
        }

        struct ViewModel {
            let module: Submodule
            let result: State
        }
    }

    /// Start search for courses
    enum SearchCourses {
        struct ViewModel {}
    }

    /// Present course list filter
    enum CourseListFilterPresentation {
        struct Request {}

        struct Response {
            let currentFilters: [CourseListFilter.Filter]
            let defaultCourseLanguage: CourseListFilter.Filter.CourseLanguage
        }

        struct ViewModel {
            let presentationDescription: CourseListFilter.PresentationDescription
        }
    }

    /// Update search results CourseListFilterQuery
    enum SearchResultsCourseListFiltersUpdate {
        struct Request {
            let filters: [CourseListFilter.Filter]
        }

        struct Response {
            let filters: [CourseListFilter.Filter]
        }

        struct ViewModel {
            let filters: [CourseListFilter.Filter]
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case normal(contentLanguage: ContentLanguage)
    }
}
