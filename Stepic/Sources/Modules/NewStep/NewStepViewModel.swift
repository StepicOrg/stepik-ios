import Foundation

struct NewStepViewModel {
    let htmlString: String
    let quizType: NewStep.QuizType?

    @available(*, deprecated, message: "Deprecated initialization")
    let step: Step
}
