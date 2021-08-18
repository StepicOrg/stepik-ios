import Foundation

struct StepQuizReviewViewModel {
    let isInstructorInstructionType: Bool
    let isPeerInstructionType: Bool
    let stage: StepQuizReview.QuizReviewStage?
    let isSubmissionCorrect: Bool
    let isSubmissionWrong: Bool

    let infoMessage: String?
    let quizTitle: String?

    let primaryActionButtonDescription: ButtonDescription

    struct ButtonDescription: UniqueIdentifiable {
        let title: String
        let isEnabled: Bool
        let uniqueIdentifier: UniqueIdentifierType
    }
}
