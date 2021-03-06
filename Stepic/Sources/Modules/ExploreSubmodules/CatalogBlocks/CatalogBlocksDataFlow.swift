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

    /// Present catalog block content item in fullscreen
    enum FullCourseListModulePresentation {
        struct Request {
            let courseListType: CourseListType
            let presentationDescription: CourseList.PresentationDescription?
        }
    }

    /// Show URL
    enum URLPresentation {
        struct Request {
            let url: URL
        }

        struct Response {
            let url: URL
        }

        struct ViewModel {
            let url: URL
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: [CatalogBlock])
    }
}
