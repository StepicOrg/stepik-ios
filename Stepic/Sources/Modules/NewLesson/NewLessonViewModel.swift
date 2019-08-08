import Foundation

struct NewLessonViewModel {
    struct StepDescription {
        let id: Step.IdType
        let iconImage: UIImage
        let isPassed: Bool
        let score: Int
        let cost: Int
        let timeToComplete: TimeInterval
    }

    let lessonTitle: String
    let steps: [StepDescription]
    let stepLinkMaker: (String) -> String
    let startStepIndex: Int
}
