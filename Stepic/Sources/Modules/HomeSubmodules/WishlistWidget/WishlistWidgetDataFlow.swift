import Foundation

enum WishlistWidget {
    /// Show wishlist
    enum WishlistLoad {
        struct Request {}

        struct Data {
            let coursesIDs: [Course.IdType]

            var isEmpty: Bool {
                self.coursesIDs.isEmpty
            }
        }

        struct Response {
            let result: StepikResult<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Present fullscreen module
    enum FullscreenCourseListModulePresentation {
        struct Request {}

        struct Response {
            let coursesIDs: [Course.IdType]
        }

        struct ViewModel {
            let coursesIDs: [Course.IdType]
        }
    }

    enum ViewControllerState {
        case loading
        case result(data: WishlistWidgetViewModel)
    }
}
