import UIKit

protocol LessonFinishedStepsPanModalPresenterProtocol {
    func presentModal(response: LessonFinishedStepsPanModal.ModalLoad.Response)
}

final class LessonFinishedStepsPanModalPresenter: LessonFinishedStepsPanModalPresenterProtocol {
    weak var viewController: LessonFinishedStepsPanModalViewControllerProtocol?

    func presentModal(response: LessonFinishedStepsPanModal.ModalLoad.Response) {
        let viewModel = self.makeViewModel(course: response.course, courseReview: response.courseReview)
        self.viewController?.displayModal(viewModel: .init(state: .result(data: viewModel)))
    }

    private func makeViewModel(course: Course, courseReview: CourseReview?) -> LessonFinishedStepsPanModalViewModel {
        let state = self.getState(course: course, courseReview: courseReview)

        let headerImageName = self.makeHeaderImageName(state: state)

        let title = self.makeTitle(course: course)
        let feedbackText = self.makeFeedbackText(course: course)
        let subtitle = self.makeSubtitle(course: course)

        let primaryActionButtonDescription = self.makePrimaryActionButtonDescription(state: state)
        let secondaryActionButtonDescription = self.makeSecondaryActionButtonDescription(state: state)

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

    private func getState(course: Course, courseReview: CourseReview?) -> State {
        let progressScore = Int(course.progress?.score ?? 0)
        let progressPercentPassed = course.progress?.percentPassed ?? 0

        let didWriteReview = courseReview != nil

        if !course.isWithCertificate {
            if progressPercentPassed < State.neutralTreshold {
                return .neutralWithoutCert
            } else if progressPercentPassed < State.successNeutralTreshold {
                return .successNeutralWithoutCert
            } else {
                return didWriteReview ? .successWithoutCertWithReview : .successWithoutCertWithoutReview
            }
        } else {
            let didReceiveCertificate = course.anyCertificateTreshold != nil
                ? (progressScore >= course.anyCertificateTreshold.require())
                : false

            if didReceiveCertificate {
                let isCertificateReady = course.certificateEntity != nil
                let isDistinctionCertIssuable = course.certificateDistinctionThreshold != nil

                if let certificateDistinctionThreshold = course.certificateDistinctionThreshold,
                   progressScore >= certificateDistinctionThreshold {
                    if progressPercentPassed < State.successNeutralTreshold {
                        return isCertificateReady
                            ? .successNeutralDistinctionCertReady
                            : .successNeutralDistinctionCertNotReady
                    } else {
                        switch (didWriteReview, isCertificateReady) {
                        case (false, true):
                            return .successDistinctionCertWithoutReviewReady
                        case (false, false):
                            return .successDistinctionCertWithoutReviewNotReady
                        case (true, true):
                            return .successDistinctionCertWithReviewReady
                        case (true, false):
                            return .successDistinctionCertWithReviewNotReady
                        }
                    }
                } else {
                    if progressPercentPassed < State.successNeutralTreshold {
                        switch (isCertificateReady, isDistinctionCertIssuable) {
                        case (true, false):
                            return .successNeutralRegularCertReadyWithoutDistinctionCert
                        case (true, true):
                            return .successNeutralRegularCertReady
                        case (false, _):
                            return .successNeutralRegularCertNotReady
                        }
                    } else {
                        switch (didWriteReview, isCertificateReady, isDistinctionCertIssuable) {
                        case (false, true, false):
                            return .successRegularCertWithoutReviewReadyWithoutDistinctionCert
                        case (false, true, true):
                            return .successRegularCertWithoutReviewReady
                        case (false, false, _):
                            return .successRegularCertWithoutReviewNotReady
                        case (true, true, false):
                            return .successRegularCertWithReviewReadyWithoutDistinctionCert
                        case (true, true, true):
                            return .successRegularCertWithReviewReady
                        case (true, false, _):
                            return .successRegularCertWithReviewNotReady
                        }
                    }
                }
            } else {
                if progressPercentPassed < State.neutralTreshold {
                    return .neutralWithCert
                } else if progressPercentPassed < State.successNeutralTreshold {
                    return .successNeutralWithCert
                } else {
                    return didWriteReview ? .successWithCertWithReview : .successWithCertWithoutReview
                }
            }
        }
    }

    private func makeHeaderImageName(state: State) -> String {
        switch state {
        case .neutralWithCert, .neutralWithoutCert:
            return "finished-steps-neutral-modal-header"
        case .successNeutralWithCert,
             .successNeutralWithoutCert,
             .successWithCertWithReview,
             .successWithCertWithoutReview:
            return "finished-steps-happy-neutral-modal-header"
        case .successWithoutCertWithoutReview, .successWithoutCertWithReview:
            return "finished-steps-success-modal-header"
        case .successNeutralRegularCertReady,
             .successNeutralRegularCertNotReady,
             .successNeutralRegularCertReadyWithoutDistinctionCert,
             .successRegularCertWithoutReviewReady,
             .successRegularCertWithoutReviewNotReady,
             .successRegularCertWithoutReviewReadyWithoutDistinctionCert,
             .successRegularCertWithReviewReady,
             .successRegularCertWithReviewNotReady,
             .successRegularCertWithReviewReadyWithoutDistinctionCert:
            return "finished-steps-regular-modal-header"
        case .successNeutralDistinctionCertReady,
             .successNeutralDistinctionCertNotReady,
             .successDistinctionCertWithoutReviewReady,
             .successDistinctionCertWithoutReviewNotReady,
             .successDistinctionCertWithReviewReady,
             .successDistinctionCertWithReviewNotReady:
            return "finished-steps-distinction-modal-header"
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
        state: State
    ) -> LessonFinishedStepsPanModalViewModel.ButtonDescription {
        switch state {
        case .successNeutralDistinctionCertReady,
             .successNeutralDistinctionCertNotReady,
             .successWithoutCertWithReview,
             .successRegularCertWithReviewReadyWithoutDistinctionCert,
             .successDistinctionCertWithReviewReady,
             .successDistinctionCertWithReviewNotReady:
            return .init(
                title: NSLocalizedString("LessonFinishedStepsPanModalActionButtonFindNewCourseTitle", comment: ""),
                iconName: nil,
                isHidden: false,
                uniqueIdentifier: LessonFinishedStepsPanModal.ActionType.findNewCourse.uniqueIdentifier
            )
        case .successWithoutCertWithoutReview,
             .successRegularCertWithoutReviewReadyWithoutDistinctionCert,
             .successDistinctionCertWithoutReviewReady,
             .successDistinctionCertWithoutReviewNotReady:
            return .init(
                title: NSLocalizedString("LessonFinishedStepsPanModalActionButtonLeaveReviewTitle", comment: ""),
                iconName: nil,
                isHidden: false,
                uniqueIdentifier: LessonFinishedStepsPanModal.ActionType.leaveReview.uniqueIdentifier
            )
        default:
            return .init(
                title: NSLocalizedString("LessonFinishedStepsPanModalActionButtonBackToAssignmentsTitle", comment: ""),
                iconName: nil,
                isHidden: false,
                uniqueIdentifier: LessonFinishedStepsPanModal.ActionType.backToAssignments.uniqueIdentifier
            )
        }
    }

    private func makeSecondaryActionButtonDescription(
        state: State
    ) -> LessonFinishedStepsPanModalViewModel.ButtonDescription {
        switch state {
        case .neutralWithCert,
             .neutralWithoutCert,
             .successNeutralWithCert,
             .successNeutralWithoutCert,
             .successWithoutCertWithoutReview,
             .successWithCertWithReview,
             .successRegularCertWithoutReviewReadyWithoutDistinctionCert,
             .successRegularCertWithReviewReady,
             .successRegularCertWithReviewNotReady,
             .successDistinctionCertWithoutReviewReady,
             .successDistinctionCertWithoutReviewNotReady:
            return .init(
                title: NSLocalizedString("LessonFinishedStepsPanModalActionButtonFindNewCourseTitle", comment: ""),
                iconName: nil,
                isHidden: false,
                uniqueIdentifier: LessonFinishedStepsPanModal.ActionType.findNewCourse.uniqueIdentifier
            )
        case .successWithCertWithoutReview,
             .successRegularCertWithoutReviewReady,
             .successRegularCertWithoutReviewNotReady:
            return .init(
                title: NSLocalizedString("LessonFinishedStepsPanModalActionButtonLeaveReviewTitle", comment: ""),
                iconName: nil,
                isHidden: false,
                uniqueIdentifier: LessonFinishedStepsPanModal.ActionType.leaveReview.uniqueIdentifier
            )
        case .successNeutralRegularCertReady,
             .successNeutralRegularCertNotReady,
             .successNeutralRegularCertReadyWithoutDistinctionCert,
             .successNeutralDistinctionCertReady,
             .successNeutralDistinctionCertNotReady,
             .successWithoutCertWithReview,
             .successRegularCertWithReviewReadyWithoutDistinctionCert,
             .successDistinctionCertWithReviewReady,
             .successDistinctionCertWithReviewNotReady:
            return .init(title: "", iconName: nil, isHidden: true, uniqueIdentifier: "")
        }
    }

    private func makePrimaryOptionButtonDescription(
        course: Course
    ) -> LessonFinishedStepsPanModalViewModel.ButtonDescription {
        .init(title: "", iconName: nil, isHidden: false, uniqueIdentifier: "")
    }

    private func makeSecondaryOptionButtonDescription(
        course: Course
    ) -> LessonFinishedStepsPanModalViewModel.ButtonDescription {
        .init(title: "", iconName: nil, isHidden: false, uniqueIdentifier: "")
    }

    private enum State {
        // ...<20
        case neutralWithCert
        case neutralWithoutCert
        // 20..<80
        case successNeutralWithCert
        case successNeutralWithoutCert
        case successNeutralRegularCertReady
        case successNeutralRegularCertNotReady
        case successNeutralRegularCertReadyWithoutDistinctionCert
        case successNeutralDistinctionCertReady
        case successNeutralDistinctionCertNotReady
        // 80...
        case successWithCertWithoutReview
        case successWithCertWithReview
        case successWithoutCertWithoutReview
        case successWithoutCertWithReview
        case successRegularCertWithoutReviewReady
        case successRegularCertWithoutReviewNotReady
        case successRegularCertWithoutReviewReadyWithoutDistinctionCert
        case successRegularCertWithReviewReady
        case successRegularCertWithReviewNotReady
        case successRegularCertWithReviewReadyWithoutDistinctionCert
        case successDistinctionCertWithoutReviewReady
        case successDistinctionCertWithoutReviewNotReady
        case successDistinctionCertWithReviewReady
        case successDistinctionCertWithReviewNotReady

        static let neutralTreshold: Float = 20
        static let successNeutralTreshold: Float = 80
    }
}
