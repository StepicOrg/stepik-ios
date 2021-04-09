import Foundation

enum StepikAcademyCourseList {
    /// Show catalog block
    enum CourseListLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<[SpecializationsCatalogBlockContentItem]>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Present Stepik Academy specialization
    enum SpecializationPresentation {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }
    }

    enum ViewControllerState {
        case loading
        case result(data: [StepikAcademyCourseListWidgetViewModel])
    }
}
