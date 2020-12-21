import Foundation

enum AuthorsCourseList {
    // MARK: Use Cases

    enum CourseListData {
        case catalogBlockContentItems([AuthorsCatalogBlockContentItem])
        case users([User])
    }

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

    /// Present author profile
    enum AuthorPresentation {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }
    }

    // MARK: Enums

    /// Module can be presented with catalogBlockID or authors ids array.
    enum Context {
        case catalogBlock(id: CatalogBlock.IdType)
        case authors(ids: [User.IdType])
    }

    enum ViewControllerState {
        case loading
        case result(data: [AuthorsCourseListWidgetViewModel])
    }
}
