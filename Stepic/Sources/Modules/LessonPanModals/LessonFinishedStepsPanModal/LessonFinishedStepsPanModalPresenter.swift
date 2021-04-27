import UIKit

protocol LessonFinishedStepsPanModalPresenterProtocol {
    func presentModal(response: LessonFinishedStepsPanModal.ModalLoad.Response)
}

final class LessonFinishedStepsPanModalPresenter: LessonFinishedStepsPanModalPresenterProtocol {
    weak var viewController: LessonFinishedStepsPanModalViewControllerProtocol?

    func presentModal(response: LessonFinishedStepsPanModal.ModalLoad.Response) {}

    private func makeViewModel(course: Course) -> LessonFinishedStepsPanModalViewModel {
        let state = self.getState(course: course)
        print("LessonFinishedStepsPanModalPresenter :: state = \(state)")

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

    private func getState(course: Course) -> State {
        let progressScore = Int(course.progress?.score ?? 0)
        let progressPercentPassed = course.progress?.percentPassed ?? 0

        if !course.isWithCertificate {
            if progressPercentPassed < 20 {
                return .neutralWithoutCert
            } else if progressPercentPassed < 80 {
                return .successNeutralWithoutCert
            } else {
                return .successWithoutCert
            }
        } else {
            let didReceiveCertificate = course.anyCertificateTreshold != nil
                ? (progressScore >= course.anyCertificateTreshold.require())
                : false

            if didReceiveCertificate {
                if let certificateDistinctionThreshold = course.certificateDistinctionThreshold,
                   progressScore >= certificateDistinctionThreshold {
                    return .successDistinctionCert
                } else {
                    return .successRegularCert
                }
            } else {
                if progressPercentPassed < 20 {
                    return .neutralWithCert
                } else if progressPercentPassed < 80 {
                    return .successNeutralWithCert
                } else {
                    return .successNeutralWithCert
                }
            }
        }
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

    private enum State {
        case neutralWithCert
        case neutralWithoutCert
        case successNeutralWithCert
        case successNeutralWithoutCert
        case successWithoutCert
        case successRegularCert
        case successDistinctionCert
    }
}
