import UIKit

protocol LessonFinishedStepsPanModalPresenterProtocol {
    func presentModal(response: LessonFinishedStepsPanModal.ModalLoad.Response)
}

final class LessonFinishedStepsPanModalPresenter: LessonFinishedStepsPanModalPresenterProtocol {
    weak var viewController: LessonFinishedStepsPanModalViewControllerProtocol?

    func presentModal(response: LessonFinishedStepsPanModal.ModalLoad.Response) {}

    private func makeViewModel(course: Course) -> LessonFinishedStepsPanModalViewModel {
        let headerImageName = self.makeHeaderImageName(course: course)

        let title = self.makeTitle(course: course)
        let feedbackText = self.makeFeedbackText(course: course)
        let subtitle = self.makeSubtitle(course: course)

        let primaryActionButtonDescription = self.makePrimaryActionButtonDescription(course: course)
        let secondaryActionButtonDescription = self.makeSecondaryActionButtonDescription(course: course)

        let primaryOptionButtonDescription = self.makePrimaryOptionButtonDescription(course: course)
        let secondaryOptionButtonDescription = self.makeSecondaryOptionButtonDescription(course: course)

        return LessonFinishedStepsPanModalViewModel(
            headerImageName: headerImageName,
            title: title,
            feedbackText: feedbackText,
            subtitle: subtitle,
            primaryActionButtonDescription: primaryActionButtonDescription,
            secondaryActionButtonDescription: secondaryActionButtonDescription,
            primaryOptionButtonDescription: primaryOptionButtonDescription,
            secondaryOptionButtonDescription: secondaryOptionButtonDescription
        )
    }

    private func makeHeaderImageName(course: Course) -> String {
        // finished-steps-distinction-modal-header
        // finished-steps-happy-neutral-modal-header
        // finished-steps-neutral-modal-header
        // finished-steps-regular-modal-header
        // finished-steps-success-modal-header
        switch course.progress?.percentPassed ?? 0 {
        case 20..<80:
            return ""
        case 80...:
            return ""
        default:
            return "finished-steps-neutral-modal-header"
        }
    }

    private func makeTitle(course: Course) -> String {
        ""
    }

    private func makeFeedbackText(course: Course) -> String {
        ""
    }

    private func makeSubtitle(course: Course) -> String {
        ""
    }

    private func makePrimaryActionButtonDescription(
        course: Course
    ) -> LessonFinishedStepsPanModalViewModel.ButtonDescription {
        .init(title: "", iconName: nil, isHidden: false)
    }

    private func makeSecondaryActionButtonDescription(
        course: Course
    ) -> LessonFinishedStepsPanModalViewModel.ButtonDescription {
        .init(title: "", iconName: nil, isHidden: false)
    }

    private func makePrimaryOptionButtonDescription(
        course: Course
    ) -> LessonFinishedStepsPanModalViewModel.ButtonDescription {
        .init(title: "", iconName: nil, isHidden: false)
    }

    private func makeSecondaryOptionButtonDescription(
        course: Course
    ) -> LessonFinishedStepsPanModalViewModel.ButtonDescription {
        .init(title: "", iconName: nil, isHidden: false)
    }
}
