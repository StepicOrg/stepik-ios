import Foundation

enum CatalogBlocks {
    // MARK: Use Cases

    /// Show catalog blocks
    enum CatalogBlocksLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<[CatalogBlock]>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Present catalog block content item of type full_course_lists in fullscreen
    enum FullCourseListModulePresentation {
        struct Request {
            let courseListType: CatalogBlockFullCourseListType
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [CatalogBlock])
    }
}
