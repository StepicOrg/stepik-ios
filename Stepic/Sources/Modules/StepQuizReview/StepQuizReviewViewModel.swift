import Foundation

struct StepQuizReviewViewModel {
    let isInstructorInstructionType: Bool
    let isPeerInstructionType: Bool
    let isSubmissionCorrect: Bool
    let isSubmissionWrong: Bool

    let stage: StepQuizReview.QuizReviewStage?
    let infoMessage: String?
    let quizTitle: String?
    let score: Float?
    let cost: Int?

    let minReviewsCount: Int?
    let givenReviewsCount: Int?
    let takenReviewsCount: Int?
    let isReviewAvailable: Bool?

    let primaryActionButtonDescription: ButtonDescription

    struct ButtonDescription: UniqueIdentifiable {
        let title: String
        let isEnabled: Bool
        let uniqueIdentifier: UniqueIdentifierType
    }
}
