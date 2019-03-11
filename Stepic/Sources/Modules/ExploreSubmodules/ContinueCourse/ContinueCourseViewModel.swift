import Foundation

struct ContinueCourseViewModel {
    typealias ProgressDescription = (description: String, value: Float)?

    let title: String
    let coverImageURL: URL?
    let progress: ProgressDescription
}
