import Foundation

struct LessonViewModel {
    struct StepDescription {
        let id: Step.IdType
        let iconImage: UIImage
        let isPassed: Bool
        let canEdit: Bool
        let isQuiz: Bool
    }

    let lessonTitle: String
    let steps: [StepDescription]
    let stepLinkMaker: (String) -> String
    let startStepIndex: Int
}
