import UIKit

protocol CourseInfoPresenterProtocol {
    func presentCourse(response: CourseInfo.CourseLoad.Response)
    func presentLesson(response: CourseInfo.LessonPresentation.Response)
    func presentPersonalDeadlinesSettings(response: CourseInfo.PersonalDeadlinesSettingsPresentation.Response)
    func presentExamLesson(response: CourseInfo.ExamLessonPresentation.Response)
    func presentCourseSharing(response: CourseInfo.CourseShareAction.Response)
    func presentLastStep(response: CourseInfo.LastStepPresentation.Response)
    func presentPreviewLesson(response: CourseInfo.PreviewLessonPresentation.Response)
    func presentAuthorization(response: CourseInfo.AuthorizationPresentation.Response)
    func presentPaidCourseBuying(response: CourseInfo.PaidCourseBuyingPresentation.Response)
    func presentIAPNotAllowed(response: CourseInfo.IAPNotAllowedPresentation.Response)
    func presentIAPReceiptValidationFailed(response: CourseInfo.IAPReceiptValidationFailedPresentation.Response)
    func presentIAPPaymentFailed(response: CourseInfo.IAPPaymentFailedPresentation.Response)
    func presentWaitingState(response: CourseInfo.BlockingWaitingIndicatorUpdate.Response)
    func presentUserCourseActionResult(response: CourseInfo.UserCourseActionPresentation.Response)
}

final class CourseInfoPresenter: CourseInfoPresenterProtocol {
    weak var viewController: CourseInfoViewControllerProtocol?

    func presentCourse(response: CourseInfo.CourseLoad.Response) {
        switch response.result {
        case .success(let data):
            let headerViewModel = self.makeHeaderViewModel(
                course: data.course,
                iapLocalizedPrice: data.iapLocalizedPrice
            )
            self.viewController?.displayCourse(viewModel: .init(state: .result(data: headerViewModel)))
        default:
            break
        }
    }

    func presentLesson(response: CourseInfo.LessonPresentation.Response) {
        self.viewController?.displayLesson(
            viewModel: CourseInfo.LessonPresentation.ViewModel(unitID: response.unitID)
        )
    }

    func presentPersonalDeadlinesSettings(response: CourseInfo.PersonalDeadlinesSettingsPresentation.Response) {
        let viewModel = CourseInfo.PersonalDeadlinesSettingsPresentation.ViewModel(
            action: response.action,
            course: response.course
        )
        self.viewController?.displayPersonalDeadlinesSettings(viewModel: viewModel)
    }

    func presentExamLesson(response: CourseInfo.ExamLessonPresentation.Response) {
        let viewModel = CourseInfo.ExamLessonPresentation.ViewModel(
            urlPath: response.urlPath
        )
        self.viewController?.displayExamLesson(viewModel: viewModel)
    }

    func presentCourseSharing(response: CourseInfo.CourseShareAction.Response) {
        let viewModel = CourseInfo.CourseShareAction.ViewModel(
            urlPath: response.urlPath
        )
        self.viewController?.displayCourseSharing(viewModel: viewModel)
    }

    func presentLastStep(response: CourseInfo.LastStepPresentation.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive
            )
        )
    }

    func presentPreviewLesson(response: CourseInfo.PreviewLessonPresentation.Response) {
        self.viewController?.displayPreviewLesson(viewModel: .init(previewLessonID: response.previewLessonID))
    }

    func presentAuthorization(response: CourseInfo.AuthorizationPresentation.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }

    func presentPaidCourseBuying(response: CourseInfo.PaidCourseBuyingPresentation.Response) {
        let path = self.makeCousePayWebURLPath(courseID: response.course.id)
        self.viewController?.displayPaidCourseBuying(viewModel: .init(urlPath: path))
    }

    func presentIAPNotAllowed(response: CourseInfo.IAPNotAllowedPresentation.Response) {
        self.viewController?.displayIAPNotAllowed(
            viewModel: .init(
                title: NSLocalizedString("IAPPurchaseFailedTitle", comment: ""),
                message: self.makeIAPErrorMessage(course: response.course, error: response.error),
                urlPath: self.makeCousePayWebURLPath(courseID: response.course.id)
            )
        )
    }

    func presentIAPReceiptValidationFailed(response: CourseInfo.IAPReceiptValidationFailedPresentation.Response) {
        self.viewController?.displayIAPReceiptValidationFailed(
            viewModel: .init(
                title: NSLocalizedString("IAPPurchaseFailedTitle", comment: ""),
                message: self.makeIAPErrorMessage(course: response.course, error: response.error)
            )
        )
    }

    func presentIAPPaymentFailed(response: CourseInfo.IAPPaymentFailedPresentation.Response) {
        self.viewController?.displayIAPPaymentFailed(
            viewModel: .init(
                title: NSLocalizedString("IAPPurchaseFailedTitle", comment: ""),
                message: self.makeIAPErrorMessage(course: response.course, error: response.error)
            )
        )
    }

    func presentWaitingState(response: CourseInfo.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    func presentUserCourseActionResult(response: CourseInfo.UserCourseActionPresentation.Response) {
        let isSuccessful = response.isSuccessful

        let message: String = {
            switch response.userCourseAction {
            case .favoriteAdd:
                return isSuccessful
                    ? NSLocalizedString("CourseInfoCourseActionAddToFavoritesSuccessMessage", comment: "")
                    : NSLocalizedString("CourseInfoCourseActionAddToFavoritesFailureMessage", comment: "")
            case .favoriteRemove:
                return isSuccessful
                    ? NSLocalizedString("CourseInfoCourseActionRemoveFromFavoritesSuccessMessage", comment: "")
                    : NSLocalizedString("CourseInfoCourseActionRemoveFromFavoritesFailureMessage", comment: "")
            case .archiveAdd:
                return isSuccessful
                    ? NSLocalizedString("CourseInfoCourseActionMoveToArchivedSuccessMessage", comment: "")
                    : NSLocalizedString("CourseInfoCourseActionMoveToArchivedFailureMessage", comment: "")
            case .archiveRemove:
                return isSuccessful
                    ? NSLocalizedString("CourseInfoCourseActionRemoveFromArchivedSuccessMessage", comment: "")
                    : NSLocalizedString("CourseInfoCourseActionRemoveFromArchivedFailureMessage", comment: "")
            }
        }()

        self.viewController?.displayUserCourseActionResult(
            viewModel: .init(isSuccessful: response.isSuccessful, message: message)
        )
    }

    private func makeCousePayWebURLPath(courseID: Course.IdType) -> String {
        "\(StepikApplicationsInfo.stepikURL)/course/\(courseID)/pay"
    }

    private func makeIAPErrorMessage(course: Course, error: Error) -> String {
        String(
            format: NSLocalizedString("IAPPurchaseFailedMessage", comment: ""),
            arguments: [
                course.title,
                error.localizedDescription
            ]
        )
    }

    private func makeProgressViewModel(progress: Progress) -> CourseInfoProgressViewModel {
        var normalizedPercent = progress.percentPassed
        normalizedPercent.round(.up)

        return CourseInfoProgressViewModel(
            progress: normalizedPercent / 100.0,
            progressLabelText: "\(progress.score)/\(progress.cost)"
        )
    }

    private func makeHeaderViewModel(course: Course, iapLocalizedPrice: String?) -> CourseInfoHeaderViewModel {
        let rating: Int = {
            if let reviewsCount = course.reviewSummary?.count,
               let averageRating = course.reviewSummary?.average,
               reviewsCount > 0 {
                return Int(round(averageRating))
            }
            return 0
        }()

        let progress: CourseInfoProgressViewModel? = {
            if let progress = course.progress {
                return self.makeProgressViewModel(progress: progress)
            }
            return nil
        }()

        let isTryForFreeAvailable = course.previewLessonID != nil && !course.enrolled
            && (course.isPaid && !course.isPurchased)

        return CourseInfoHeaderViewModel(
            title: course.title,
            coverImageURL: URL(string: course.coverURLString),
            rating: rating,
            learnersLabelText: FormatterHelper.longNumber(course.learnersCount ?? 0),
            progress: progress,
            isVerified: (course.readiness ?? 0) > 0.9,
            isEnrolled: course.enrolled,
            isFavorite: course.isFavorite,
            isArchived: course.isArchived,
            isTryForFreeAvailable: isTryForFreeAvailable,
            buttonDescription: self.makeButtonDescription(course: course, iapLocalizedPrice: iapLocalizedPrice)
        )
    }

    private func makeButtonDescription(
        course: Course,
        iapLocalizedPrice: String?
    ) -> CourseInfoHeaderViewModel.ButtonDescription {
        let isEnrolled = course.enrolled
        let isEnabled = isEnrolled ? course.canContinue : true
        let title: String = {
            if isEnrolled {
                return NSLocalizedString("WidgetButtonLearn", comment: "")
            }

            if course.isPaid && !course.isPurchased {
                let displayPrice = iapLocalizedPrice ?? course.displayPrice
                if let displayPrice = displayPrice {
                    return String(format: NSLocalizedString("WidgetButtonBuy", comment: ""), displayPrice)
                }
            }

            return NSLocalizedString("WidgetButtonJoin", comment: "")
        }()

        return CourseInfoHeaderViewModel.ButtonDescription(
            title: title,
            isCallToAction: !isEnrolled,
            isEnabled: isEnabled
        )
    }
}
