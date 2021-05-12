import Foundation

enum LessonFinishedStepsPanModal {
    enum ModalLoad {
        struct Request {}

        struct Response {
            let course: Course
            let courseReview: CourseReview?
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: Enums

    enum ActionType: String, UniqueIdentifiable {
        case backToAssignments
        case leaveReview
        case findNewCourse

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }
    }

    enum ViewControllerState {
        case loading
        case result(data: LessonFinishedStepsPanModalViewModel)
    }
}
