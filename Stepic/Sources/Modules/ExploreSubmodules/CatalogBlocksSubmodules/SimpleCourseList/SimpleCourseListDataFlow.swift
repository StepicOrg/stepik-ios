import Foundation

enum SimpleCourseList {
    // MARK: Use Cases

    /// Show catalog block
    enum CourseListLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<[SimpleCourseListsCatalogBlockContentItem]>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Present course list in fullscreen
    enum CourseListModulePresentation {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }
    }

    // MARK: Enums

    enum LayoutType {
        case `default`
        case grid

        init(catalogBlockAppearance: CatalogBlockAppearance) {
            switch catalogBlockAppearance {
            case .default:
                self = .default
            case .simpleCourseListsGrid:
                self = .grid
            }
        }
    }

    enum ViewControllerState {
        case loading
        case result(data: [SimpleCourseListWidgetViewModel])
    }
}
