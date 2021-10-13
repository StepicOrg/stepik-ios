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

    enum ModalAction {
        struct Request {
            let actionUniqueIdentifier: UniqueIdentifierType
        }
    }

    enum ShareResultPresentation {
        struct Response {
            let course: Course
        }

        struct ViewModel {
            let text: String
        }
    }

    enum CertificatePresentation {
        struct Response {
            let certificate: Certificate
        }

        struct ViewModel {
            let certificateURL: URL
        }
    }

    enum BackToAssignmentsPresentation {
        struct Response {}

        struct ViewModel {}
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
