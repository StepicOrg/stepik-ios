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

        let title = self.makeTitle(course: course, state: state)
        let feedbackText = self.makeFeedbackText(course: course, state: state)
        let subtitle = self.makeSubtitle(course: course, state: state)

        let primaryActionButtonDescription = self.makePrimaryActionButtonDescription(state: state)
        let secondaryActionButtonDescription = self.makeSecondaryActionButtonDescription(state: state)

        let primaryOptionButtonDescription = self.makePrimaryOptionButtonDescription(state: state)
        let secondaryOptionButtonDescription = self.makeSecondaryOptionButtonDescription(state: state)

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
        let progressScore = course.progress?.score ?? 0
        let progressPercentPassed = course.progress?.percentPassed ?? 0

        let didWriteReview = courseReview != nil

        if !course.isWithCertificate {
            if progressPercentPassed < State.neutralThreshold {
                return .neutralWithoutCert
            } else if progressPercentPassed < State.successNeutralThreshold {
                return .successNeutralWithoutCert
            } else {
                return didWriteReview ? .successWithoutCertWithReview : .successWithoutCertWithoutReview
            }
        } else {
            let didReceiveCertificate = course.anyCertificateTreshold != nil
                ? (progressScore >= Float(course.anyCertificateTreshold.require()))
                : false

            if didReceiveCertificate {
                let isCertificateReady = course.certificateEntity != nil
                let isDistinctionCertIssuable = course.certificateDistinctionThreshold != nil

                if let certificateDistinctionThreshold = course.certificateDistinctionThreshold,
                   progressScore >= Float(certificateDistinctionThreshold) {
                    if progressPercentPassed < State.successNeutralThreshold {
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
                    if progressPercentPassed < State.successNeutralThreshold {
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
                if progressPercentPassed < State.neutralThreshold {
                    return .neutralWithCert
                } else if progressPercentPassed < State.successNeutralThreshold {
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

    private func makeTitle(course: Course, state: State) -> String {
        switch state {
        case .neutralWithCert,
             .neutralWithoutCert:
            return String(
                format: NSLocalizedString("LessonFinishedStepsPanModalTitleFinishedCourse", comment: ""),
                arguments: [course.title]
            )
        case .successNeutralWithCert,
             .successNeutralWithoutCert,
             .successNeutralDistinctionCertReady,
             .successNeutralDistinctionCertNotReady,
             .successWithCertWithoutReview,
             .successWithCertWithReview,
             .successWithoutCertWithoutReview,
             .successWithoutCertWithReview,
             .successDistinctionCertWithoutReviewReady,
             .successDistinctionCertWithoutReviewNotReady,
             .successDistinctionCertWithReviewReady,
             .successDistinctionCertWithReviewNotReady:
            return String(
                format: NSLocalizedString("LessonFinishedStepsPanModalTitleFinishedCourseWithSuccess", comment: ""),
                arguments: [course.title]
            )
        case .successNeutralRegularCertReady,
             .successNeutralRegularCertNotReady,
             .successNeutralRegularCertReadyWithoutDistinctionCert,
             .successRegularCertWithoutReviewReady,
             .successRegularCertWithoutReviewNotReady,
             .successRegularCertWithoutReviewReadyWithoutDistinctionCert,
             .successRegularCertWithReviewReady,
             .successRegularCertWithReviewNotReady,
             .successRegularCertWithReviewReadyWithoutDistinctionCert:
            return String(
                format: NSLocalizedString(
                    "LessonFinishedStepsPanModalTitleFinishedCourseWithSuccessAndCertificate",
                    comment: ""
                ),
                arguments: [course.title]
            )
        }
    }

    private func makeFeedbackText(course: Course, state: State) -> String {
        switch state {
        case .neutralWithCert,
             .successNeutralWithCert,
             .successWithCertWithoutReview,
             .successWithCertWithReview:
            let progressScore = course.progress?.score ?? 0
            let anyCertificateThreshold = Float(course.anyCertificateTreshold ?? 0)

            let needScore = anyCertificateThreshold - progressScore

            return String(
                format: NSLocalizedString("LessonFinishedStepsPanModalCertificateFeedback", comment: ""),
                arguments: [FormatterHelper.pointsCount(needScore)]
            )
        default:
            return ""
        }
    }

    private func makeSubtitle(course: Course, state: State) -> String {
        let progressScore = course.progress?.score ?? 0
        let progressCost = course.progress?.cost ?? 0
        let progressPercentPassed = course.progress?.percentPassed ?? 0

        let formattedScore = FormatterHelper.pointsCount(progressScore)
        let formattedProgressPercentPassed = FormatterHelper.integerPercent(progressPercentPassed / 100.0)
        let formattedProgress = String(
            format: NSLocalizedString("LessonFinishedStepsPanModalSubtitleProgress", comment: ""),
            arguments: [formattedScore, "\(progressCost)", formattedProgressPercentPassed]
        )

        let formattedDistinctionCertNeedScore: String = {
            let certificateDistinctionThreshold = course.certificateDistinctionThreshold ?? 0
            let needScore = Float(certificateDistinctionThreshold) - progressScore

            let formattedDistinctionThreshold = FormatterHelper.pointsCount(certificateDistinctionThreshold)
            let formattedNeedScore = FormatterHelper.progressScore(needScore)

            return String(
                format: NSLocalizedString(
                    "LessonFinishedStepsPanModalSubtitleCertificateDistinctionNeedScoreMessage",
                    comment: ""
                ),
                arguments: [formattedDistinctionThreshold, formattedNeedScore]
            )
        }()

        let certificateHint = NSLocalizedString("LessonFinishedStepsPanModalSubtitleCertificateHint", comment: "")
        let certificateReadyMessage = NSLocalizedString(
            "LessonFinishedStepsPanModalSubtitleCertificateReadyMessage",
            comment: ""
        )
        let certificateNotReadyMessage = NSLocalizedString(
            "LessonFinishedStepsPanModalSubtitleCertificateNotReadyNotifyMessage",
            comment: ""
        )

        switch state {
        case .neutralWithCert,
             .successNeutralWithCert,
             .successWithCertWithoutReview,
             .successWithCertWithReview:
            let certificateRegularThreshold = course.certificateRegularThreshold ?? 0
            let formattedCertificateRegularThreshold = FormatterHelper.pointsCount(certificateRegularThreshold)

            let formattedCertificateIssuedMessage: String = {
                if let certificateDistinctionThreshold = course.certificateDistinctionThreshold {
                    return String(
                        format: NSLocalizedString(
                            "LessonFinishedStepsPanModalSubtitleCertificateIssuedMessage",
                            comment: ""
                        ),
                        arguments: [formattedCertificateRegularThreshold, "\(certificateDistinctionThreshold)"]
                    )
                } else {
                    return String(
                        format: NSLocalizedString(
                            "LessonFinishedStepsPanModalSubtitleCertificateWithoutDistinctionIssuedMessage",
                            comment: ""
                        ),
                        arguments: [formattedCertificateRegularThreshold]
                    )
                }
            }()

            return "\(formattedProgress) \(formattedCertificateIssuedMessage)\n\n\(certificateHint)"
        case .neutralWithoutCert:
            let withoutCertMessage = NSLocalizedString(
                "LessonFinishedStepsPanModalSubtitleCertificateNotIssuedNeutralMessage",
                comment: ""
            )
            let continueMessage = NSLocalizedString("LessonFinishedStepsPanModalSubtitleContinueMessage", comment: "")

            return "\(formattedProgress) \(withoutCertMessage)\n\n\(continueMessage)"
        case .successNeutralWithoutCert,
             .successWithoutCertWithoutReview,
             .successWithoutCertWithReview:
            let withoutCertMessage = NSLocalizedString(
                "LessonFinishedStepsPanModalSubtitleCertificateNotIssuedSuccessMessage",
                comment: ""
            )

            return "\(formattedProgress) \(withoutCertMessage)"
        case .successNeutralRegularCertReady,
             .successRegularCertWithoutReviewReady,
             .successRegularCertWithReviewReady:
            return "\(formattedProgress) \(formattedDistinctionCertNeedScore)\n\n\(certificateReadyMessage)"
        case .successNeutralRegularCertNotReady,
             .successRegularCertWithoutReviewNotReady,
             .successRegularCertWithReviewNotReady:
            return "\(formattedProgress) \(formattedDistinctionCertNeedScore)\n\n\(certificateNotReadyMessage) \(certificateHint)"
        case .successNeutralRegularCertReadyWithoutDistinctionCert,
             .successNeutralDistinctionCertReady,
             .successRegularCertWithoutReviewReadyWithoutDistinctionCert,
             .successRegularCertWithReviewReadyWithoutDistinctionCert,
             .successDistinctionCertWithoutReviewReady,
             .successDistinctionCertWithReviewReady:
            return "\(formattedProgress)\n\n\(certificateReadyMessage)"
        case .successNeutralDistinctionCertNotReady,
             .successDistinctionCertWithoutReviewNotReady,
             .successDistinctionCertWithReviewNotReady:
            return "\(formattedProgress)\n\n\(certificateNotReadyMessage) \(certificateHint)"
        }
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
        state: State
    ) -> LessonFinishedStepsPanModalViewModel.ButtonDescription {
        switch state {
        case .successNeutralWithoutCert,
             .successNeutralWithCert,
             .successNeutralRegularCertReady,
             .successNeutralRegularCertNotReady,
             .successNeutralRegularCertReadyWithoutDistinctionCert,
             .successNeutralDistinctionCertReady,
             .successNeutralDistinctionCertNotReady,
             .successWithCertWithoutReview,
             .successWithCertWithReview,
             .successWithoutCertWithoutReview,
             .successWithoutCertWithReview,
             .successRegularCertWithoutReviewReady,
             .successRegularCertWithoutReviewNotReady,
             .successRegularCertWithoutReviewReadyWithoutDistinctionCert,
             .successRegularCertWithReviewReady,
             .successRegularCertWithReviewNotReady,
             .successRegularCertWithReviewReadyWithoutDistinctionCert,
             .successDistinctionCertWithoutReviewReady,
             .successDistinctionCertWithoutReviewNotReady,
             .successDistinctionCertWithReviewReady,
             .successDistinctionCertWithReviewNotReady:
            return .init(
                title: NSLocalizedString("LessonFinishedStepsPanModalActionButtonShareResultTitle", comment: ""),
                iconName: "finished-steps-button-share",
                isHidden: false,
                uniqueIdentifier: LessonFinishedStepsPanModal.ActionType.shareResult.uniqueIdentifier
            )
        default:
            return .init(title: "", iconName: nil, isHidden: true, uniqueIdentifier: "")
        }
    }

    private func makeSecondaryOptionButtonDescription(
        state: State
    ) -> LessonFinishedStepsPanModalViewModel.ButtonDescription {
        switch state {
        case .successNeutralRegularCertReady,
             .successNeutralRegularCertReadyWithoutDistinctionCert,
             .successNeutralDistinctionCertReady,
             .successRegularCertWithoutReviewReady,
             .successRegularCertWithoutReviewReadyWithoutDistinctionCert,
             .successRegularCertWithReviewReady,
             .successRegularCertWithReviewReadyWithoutDistinctionCert,
             .successDistinctionCertWithoutReviewReady,
             .successDistinctionCertWithReviewReady:
            return .init(
                title: NSLocalizedString("LessonFinishedStepsPanModalActionButtonViewCertificateTitle", comment: ""),
                iconName: "finished-steps-button-certificate",
                isHidden: false,
                uniqueIdentifier: LessonFinishedStepsPanModal.ActionType.viewCertificate.uniqueIdentifier
            )
        default:
            return .init(title: "", iconName: nil, isHidden: true, uniqueIdentifier: "")
        }
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

        static let neutralThreshold: Float = 20
        static let successNeutralThreshold: Float = 80
    }
}
