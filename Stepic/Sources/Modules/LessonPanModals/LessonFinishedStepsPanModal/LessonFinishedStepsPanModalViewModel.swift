import Foundation

struct LessonFinishedStepsPanModalViewModel {
    let headerImageName: String

    let title: String
    let feedbackText: String
    let subtitle: String

    let primaryActionButtonDescription: ButtonDescription
    let secondaryActionButtonDescription: ButtonDescription

    let primaryOptionButtonDescription: ButtonDescription
    let secondaryOptionButtonDescription: ButtonDescription

    struct ButtonDescription: UniqueIdentifiable {
        let title: String
        let iconName: String?
        let isHidden: Bool
        let uniqueIdentifier: UniqueIdentifierType
    }
}
