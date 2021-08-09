import Foundation

struct StepQuizReviewViewModel {
    let isInstructorInstructionType: Bool
    let isPeerInstructionType: Bool
    let isTeacher: Bool

    let infoMessage: String?

    let primaryActionButtonDescription: ButtonDescription

    struct ButtonDescription: UniqueIdentifiable {
        let title: String
        let isEnabled: Bool
        let uniqueIdentifier: UniqueIdentifierType
    }
}
