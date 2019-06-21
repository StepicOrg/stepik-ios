import UIKit

struct CourseWidgetProgressViewModel {
    let progress: Float
    let progressLabelText: String
}

struct CourseWidgetViewModel: UniqueIdentifiable {
    typealias ButtonDescription = (title: String, isCallToAction: Bool)

    let title: String
    let coverImageURL: URL?
    let primaryButtonDescription: ButtonDescription
    let secondaryButtonDescription: ButtonDescription
    let learnersLabelText: String
    let ratingLabelText: String?
    let isAdaptive: Bool
    let progress: CourseWidgetProgressViewModel?
    let uniqueIdentifier: UniqueIdentifierType
}
