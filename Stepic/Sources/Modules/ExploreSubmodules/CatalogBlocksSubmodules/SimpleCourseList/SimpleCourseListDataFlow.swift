import Foundation

enum SimpleCourseList {
    // MARK: Common Types

    enum CourseListData {
        case catalogBlockContentItems([SimpleCourseListsCatalogBlockContentItem])
        case courseLists([CourseListModel])
    }

    // MARK: Use Cases

    /// Show catalog block
    enum CourseListLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<CourseListData>
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

    /// Module can be presented with catalogBlockID or course lists ids array.
    enum Context {
        case catalogBlock(id: CatalogBlock.IdType)
        case courseLists(ids: [CourseListModel.IdType])
    }

    enum LayoutType {
        case `default`
        case grid

        init(catalogBlockAppearance: CatalogBlockAppearance) {
            switch catalogBlockAppearance {
            case .simpleCourseListsGrid:
                self = .grid
            default:
                self = .default
            }
        }
    }

    enum ViewControllerState {
        case loading
        case result(data: [SimpleCourseListWidgetViewModel])
    }
}
