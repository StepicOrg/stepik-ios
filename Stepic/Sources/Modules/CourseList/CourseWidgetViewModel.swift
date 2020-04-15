import UIKit

struct CourseWidgetProgressViewModel {
    let progress: Float
    let progressLabelText: String
}

struct CourseWidgetViewModel: UniqueIdentifiable {
    let title: String
    let summary: String
    let coverImageURL: URL?
    let learnersLabelText: String
    let ratingLabelText: String?
    let isAdaptive: Bool
    let isEnrolled: Bool
    let progress: CourseWidgetProgressViewModel?
    let uniqueIdentifier: UniqueIdentifierType
}
