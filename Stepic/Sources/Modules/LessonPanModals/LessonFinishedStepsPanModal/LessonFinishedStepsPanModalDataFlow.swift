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

    enum ShareResultPresentation {
        struct Request {}

        struct Response {
            let course: Course
        }

        struct ViewModel {
            let text: String
        }
    }

    enum CertificatePresentation {
        struct Request {}

        struct Response {
            let certificate: Certificate
        }

        struct ViewModel {
            let certificateURL: URL
        }
    }

    // MARK: Enums

    enum ActionType: String, UniqueIdentifiable {
        case backToAssignments
        case leaveReview
        case findNewCourse
        case shareResult
        case viewCertificate

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }
    }

    enum ViewControllerState {
        case loading
        case result(data: LessonFinishedStepsPanModalViewModel)
    }
}
