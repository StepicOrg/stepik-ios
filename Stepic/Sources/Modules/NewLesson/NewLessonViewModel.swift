import Foundation

struct NewLessonViewModel {
    typealias StepDescription = (id: Step.IdType, iconImage: UIImage)

    let lessonTitle: String
    let steps: [StepDescription]
}
