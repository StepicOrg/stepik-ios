import Foundation

struct CourseInfoProgressViewModel {
    let progress: Float
    let progressLabelText: String
}

struct CourseInfoHeaderViewModel {
    let title: String
    let coverImageURL: URL?

    let rating: Int
    let learnersLabelText: String
    let progress: CourseInfoProgressViewModel?
    let isVerified: Bool
    let isEnrolled: Bool
}
