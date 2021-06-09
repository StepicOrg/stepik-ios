import UIKit

protocol CourseInfoPresenterProtocol {
    func presentCourse(response: CourseInfo.CourseLoad.Response)
    func presentLesson(response: CourseInfo.LessonPresentation.Response)
    func presentPersonalDeadlinesSettings(response: CourseInfo.PersonalDeadlinesSettingsPresentation.Response)
    func presentExamLesson(response: CourseInfo.ExamLessonPresentation.Response)
    func presentCourseSharing(response: CourseInfo.CourseShareAction.Response)
    func presentLastStep(response: CourseInfo.LastStepPresentation.Response)
    func presentLessonModuleBuyCourseAction(response: CourseInfo.LessonModuleBuyCourseActionPresentation.Response)
    func presentLessonModuleCatalogAction(response: CourseInfo.LessonModuleCatalogPresentation.Response)
    func presentLessonModuleWriteReviewAction(response: CourseInfo.LessonModuleWriteReviewPresentation.Response)
    func presentPreviewLesson(response: CourseInfo.PreviewLessonPresentation.Response)
    func presentAuthorization(response: CourseInfo.AuthorizationPresentation.Response)
    func presentPaidCourseBuying(response: CourseInfo.PaidCourseBuyingPresentation.Response)
    func presentIAPNotAllowed(response: CourseInfo.IAPNotAllowedPresentation.Response)
    func presentIAPReceiptValidationFailed(response: CourseInfo.IAPReceiptValidationFailedPresentation.Response)
    func presentIAPPaymentFailed(response: CourseInfo.IAPPaymentFailedPresentation.Response)
    func presentWaitingState(response: CourseInfo.BlockingWaitingIndicatorUpdate.Response)
    func presentUserCourseActionResult(response: CourseInfo.UserCourseActionPresentation.Response)
    func presentWishlistMainActionResult(response: CourseInfo.CourseWishlistMainAction.Response)
}

final class CourseInfoPresenter: CourseInfoPresenterProtocol {
    weak var viewController: CourseInfoViewControllerProtocol?

    private let urlFactory: StepikURLFactory

    init(urlFactory: StepikURLFactory) {
        self.urlFactory = urlFactory
    }

    func presentCourse(response: CourseInfo.CourseLoad.Response) {
        switch response.result {
        case .success(let data):
            let headerViewModel = self.makeHeaderViewModel(
                course: data.course,
                isWishlisted: data.isWishlisted,
                isWishlistAvailable: data.isWishlistAvailable,
                iapLocalizedPrice: data.iapLocalizedPrice,
                promoCode: data.promoCode
            )
            self.viewController?.displayCourse(viewModel: .init(state: .result(data: headerViewModel)))
        case .failure:
            self.viewController?.displayCourse(viewModel: .init(state: .error))
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
        var url = response.url

        if let deepLinkQueryParameters = self.getDeepLinkQueryParameters(courseViewSource: response.courseViewSource) {
            url.appendQueryParameters(deepLinkQueryParameters)
        }

        self.viewController?.displayCourseSharing(viewModel: .init(urlPath: url.absoluteString))
    }

    func presentLastStep(response: CourseInfo.LastStepPresentation.Response) {
        self.viewController?.displayLastStep(
            viewModel: .init(
                course: response.course,
                isAdaptive: response.isAdaptive,
                courseViewSource: response.courseViewSource
            )
        )
    }

    func presentLessonModuleBuyCourseAction(response: CourseInfo.LessonModuleBuyCourseActionPresentation.Response) {
        self.viewController?.displayLessonModuleBuyCourseAction(viewModel: .init())
    }

    func presentLessonModuleCatalogAction(response: CourseInfo.LessonModuleCatalogPresentation.Response) {
        self.viewController?.displayLessonModuleCatalogAction(viewModel: .init())
    }

    func presentLessonModuleWriteReviewAction(response: CourseInfo.LessonModuleWriteReviewPresentation.Response) {
        self.viewController?.displayLessonModuleWriteReviewAction(viewModel: .init())
    }

    func presentPreviewLesson(response: CourseInfo.PreviewLessonPresentation.Response) {
        self.viewController?.displayPreviewLesson(viewModel: .init(previewLessonID: response.previewLessonID))
    }

    func presentAuthorization(response: CourseInfo.AuthorizationPresentation.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }

    func presentPaidCourseBuying(response: CourseInfo.PaidCourseBuyingPresentation.Response) {
        guard var payForCourseURL = self.urlFactory.makePayForCourse(id: response.course.id) else {
            return
        }

        if let deepLinkQueryParameters = self.getDeepLinkQueryParameters(courseViewSource: response.courseViewSource) {
            payForCourseURL.appendQueryParameters(deepLinkQueryParameters)
        }

        self.viewController?.displayPaidCourseBuying(viewModel: .init(urlPath: payForCourseURL.absoluteString))
    }

    func presentIAPNotAllowed(response: CourseInfo.IAPNotAllowedPresentation.Response) {
        if let payForCourseURL = self.urlFactory.makePayForCourse(id: response.course.id) {
            self.viewController?.displayIAPNotAllowed(
                viewModel: .init(
                    title: NSLocalizedString("IAPPurchaseFailedTitle", comment: ""),
                    message: self.makeIAPErrorMessage(course: response.course, error: response.error),
                    urlPath: payForCourseURL.absoluteString
                )
            )
        }
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

    func presentWishlistMainActionResult(response: CourseInfo.CourseWishlistMainAction.Response) {
        let isSuccessful = response.isSuccessful

        let message: String = {
            switch response.action {
            case .add:
                return isSuccessful
                    ? NSLocalizedString("CourseInfoAddToWishlistSuccessMessage", comment: "")
                    : NSLocalizedString("CourseInfoAddToWishlistFailureMessage", comment: "")
            case .remove:
                return isSuccessful
                    ? NSLocalizedString("CourseInfoRemoveFromWishlistSuccessMessage", comment: "")
                    : NSLocalizedString("CourseInfoRemoveFromWishlistFailureMessage", comment: "")
            }
        }()

        self.viewController?.displayWishlistMainActionResult(
            viewModel: .init(isSuccessful: isSuccessful, message: message)
        )
    }

    // MARK: Private API

    private func makeIAPErrorMessage(course: Course, error: Error) -> String {
        String(
            format: NSLocalizedString("IAPPurchaseFailedMessage", comment: ""),
            arguments: [
                course.title,
                error.localizedDescription
            ]
        )
    }

    private func getDeepLinkQueryParameters(courseViewSource: AnalyticsEvent.CourseViewSource) -> [String: String]? {
        guard case .deepLink(let urlString) = courseViewSource,
              let queryItems = URLComponents(string: urlString)?.queryItems else {
            return nil
        }

        let keysWithValues = queryItems.compactMap { queryItem -> (String, String)? in
            if let value = queryItem.value {
                return (queryItem.name, value)
            }
            return nil
        }

        return Dictionary(uniqueKeysWithValues: keysWithValues)
    }

    private func makeProgressViewModel(progress: Progress) -> CourseInfoProgressViewModel {
        var normalizedPercent = progress.percentPassed
        normalizedPercent.round(.up)

        return CourseInfoProgressViewModel(
            progress: normalizedPercent / 100.0,
            progressLabelText: "\(FormatterHelper.progressScore(progress.score))/\(progress.cost)"
        )
    }

    private func makeHeaderViewModel(
        course: Course,
        isWishlisted: Bool,
        isWishlistAvailable: Bool,
        iapLocalizedPrice: String?,
        promoCode: PromoCode?
    ) -> CourseInfoHeaderViewModel {
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
            isWishlisted: isWishlisted,
            isWishlistAvailable: isWishlistAvailable,
            isTryForFreeAvailable: isTryForFreeAvailable,
            buttonDescription: self.makeButtonDescription(
                course: course,
                iapLocalizedPrice: iapLocalizedPrice,
                promoCode: promoCode
            )
        )
    }

    private func makeButtonDescription(
        course: Course,
        iapLocalizedPrice: String?,
        promoCode: PromoCode?
    ) -> CourseInfoHeaderViewModel.ButtonDescription {
        let isEnrolled = course.enrolled
        let isEnabled = isEnrolled ? course.canContinue : true
        let isNotPurchased = course.isPaid && !course.isPurchased
        var isPromo = false

        let title: String = {
            if isEnrolled {
                return NSLocalizedString("WidgetButtonLearn", comment: "")
            }

            if isNotPurchased {
                let displayPrice: String?
                if let iapLocalizedPrice = iapLocalizedPrice {
                    displayPrice = iapLocalizedPrice
                } else if let promoCode = promoCode {
                    displayPrice = FormatterHelper.price(promoCode.price, currencyCode: promoCode.currencyCode)
                    isPromo = true
                } else {
                    displayPrice = course.displayPrice
                }

                if let displayPrice = displayPrice {
                    return String(format: NSLocalizedString("WidgetButtonBuy", comment: ""), displayPrice)
                }
            }

            return NSLocalizedString("WidgetButtonJoin", comment: "")
        }()

        let subtitle: String? = {
            if isNotPurchased && promoCode != nil {
                return course.displayPrice
            }
            return nil
        }()

        return CourseInfoHeaderViewModel.ButtonDescription(
            title: title,
            subtitle: subtitle,
            isCallToAction: !isEnrolled,
            isEnabled: isEnabled,
            isPromo: isPromo
        )
    }
}
