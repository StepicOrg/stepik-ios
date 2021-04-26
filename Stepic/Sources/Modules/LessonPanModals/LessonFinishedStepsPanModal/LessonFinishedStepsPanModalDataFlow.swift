import Foundation

enum LessonFinishedStepsPanModal {
    enum ModalLoad {
        struct Request {}

        struct Response {
            let course: Course
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: Enums

    enum ViewControllerState {
        case loading
        case result(data: LessonFinishedStepsPanModalViewModel)
    }
}
