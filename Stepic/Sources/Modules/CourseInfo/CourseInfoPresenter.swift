import UIKit

protocol CourseInfoPresenterProtocol {
    func presentCourse(response: CourseInfo.CourseLoad.Response)
    func presentLesson(response: CourseInfo.LessonPresentation.Response)
    func presentPersonalDeadlinesSettings(response: CourseInfo.PersonalDeadlinesSettingsPresentation.Response)
    func presentExamLesson(response: CourseInfo.ExamLessonPresentation.Response)
    func presentCourseSharing(response: CourseInfo.CourseShareAction.Response)
    func presentLastStep(response: CourseInfo.LastStepPresentation.Response)
    func presentPurchaseModalStartLearning(response: CourseInfo.PurchaseModalStartLearningPresentation.Response)
    func presentLessonModuleBuyCourseAction(response: CourseInfo.LessonModuleBuyCourseActionPresentation.Response)
    func presentLessonModuleCatalogAction(response: CourseInfo.LessonModuleCatalogPresentation.Response)
    func presentLessonModuleWriteReviewAction(response: CourseInfo.LessonModuleWriteReviewPresentation.Response)
    func presentPreviewLesson(response: CourseInfo.PreviewLessonPresentation.Response)
    func presentCourseRevenue(response: CourseInfo.CourseRevenuePresentation.Response)
    func presentAuthorization(response: CourseInfo.AuthorizationPresentation.Response)
    func presentPaidCourseBuying(response: CourseInfo.PaidCourseBuyingPresentation.Response)
    func presentPaidCoursePurchaseModal(response: CourseInfo.PaidCoursePurchaseModalPresentation.Response)
    func presentPaidCourseRestorePurchaseResult(response: CourseInfo.PaidCourseRestorePurchase.Response)
    func presentIAPNotAllowed(response: CourseInfo.IAPNotAllowedPresentation.Response)
    func presentIAPReceiptValidationFailed(response: CourseInfo.IAPReceiptValidationFailedPresentation.Response)
    func presentIAPPaymentFailed(response: CourseInfo.IAPPaymentFailedPresentation.Response)
    func presentWaitingState(response: CourseInfo.BlockingWaitingIndicatorUpdate.Response)
    func presentUserCourseActionResult(response: CourseInfo.UserCourseActionPresentation.Response)
    func presentWishlistMainActionResult(response: CourseInfo.CourseWishlistMainAction.Response)
    func presentCourseContentSearch(response: CourseInfo.CourseContentSearchPresentation.Response)
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
                coursePurchaseFlow: data.coursePurchaseFlow,
                isWishlistAvailable: data.isWishlistAvailable,
                isCourseRevenueAvailable: data.isCourseRevenueAvailable,
                promoCode: data.promoCode,
                mobileTier: data.mobileTier,
                shouldCheckIAPPurchaseSupport: data.shouldCheckIAPPurchaseSupport,
                isSupportedIAPPurchase: data.isSupportedIAPPurchase,
                isRestorePurchaseAvailable: data.isRestorePurchaseAvailable
            )
            self.viewController?.displayCourse(viewModel: .init(state: .result(data: headerViewModel)))
        case .failure:
            self.viewController?.displayCourse(viewModel: .init(state: .error))
        }
    }

    func presentLesson(response: CourseInfo.LessonPresentation.Response) {
        self.viewController?.displayLesson(
            viewModel: .init(unitID: response.unitID, promoCodeName: response.promoCodeName)
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
            urlPath: response.url.absoluteString
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

    func presentPurchaseModalStartLearning(response: CourseInfo.PurchaseModalStartLearningPresentation.Response) {
        self.viewController?.displayPurchaseModalStartLearning(
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
        self.viewController?.displayPreviewLesson(
            viewModel: .init(
                previewLessonID: response.previewLessonID,
                previewUnitID: response.previewUnitID,
                promoCodeName: response.promoCodeName
            )
        )
    }

    func presentCourseRevenue(response: CourseInfo.CourseRevenuePresentation.Response) {
        self.viewController?.displayCourseRevenue(viewModel: .init(courseID: response.courseID))
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

    func presentPaidCoursePurchaseModal(response: CourseInfo.PaidCoursePurchaseModalPresentation.Response) {
        self.viewController?.displayPaidCoursePurchaseModal(
            viewModel: .init(
                courseID: response.courseID,
                promoCodeName: response.promoCodeName,
                mobileTierID: response.mobileTierID,
                courseBuySource: response.courseBuySource
            )
        )
    }

    func presentPaidCourseRestorePurchaseResult(response: CourseInfo.PaidCourseRestorePurchase.Response) {
        switch response.state {
        case .inProgress:
            self.viewController?.displayPaidCourseRestorePurchaseResult(viewModel: .init(state: .inProgress))
        case .error(let error):
            let title = NSLocalizedString("CourseInfoRestorePurchaseErrorTitle", comment: "")
            let message = String(
                format: NSLocalizedString("CourseInfoRestorePurchaseErrorMessage", comment: ""),
                arguments: [error.localizedDescription]
            )

            self.viewController?.displayPaidCourseRestorePurchaseResult(
                viewModel: .init(state: .error(title: title, message: message))
            )
        case .success:
            let message = NSLocalizedString("CourseInfoRestorePurchaseSuccessMessage", comment: "")
            self.viewController?.displayPaidCourseRestorePurchaseResult(
                viewModel: .init(state: .success(message: message))
            )
        }
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

    func presentCourseContentSearch(response: CourseInfo.CourseContentSearchPresentation.Response) {
        self.viewController?.displayCourseContentSearch(viewModel: .init(courseID: response.courseID))
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
        coursePurchaseFlow: CoursePurchaseFlowType,
        isWishlistAvailable: Bool,
        isCourseRevenueAvailable: Bool,
        promoCode: PromoCode?,
        mobileTier: MobileTierPlainObject?,
        shouldCheckIAPPurchaseSupport: Bool,
        isSupportedIAPPurchase: Bool,
        isRestorePurchaseAvailable: Bool
    ) -> CourseInfoHeaderViewModel {
        let rating = course.reviewSummary?.rating ?? 0

        let progress: CourseInfoProgressViewModel? = {
            if let progress = course.progress {
                return self.makeProgressViewModel(progress: progress)
            }
            return nil
        }()

        let isTryForFreeAvailable = course.previewLessonID != nil && !course.enrolled
            && (course.isPaid && !course.isPurchased)

        let purchaseFeedbackText: String? = {
            if course.enrolled {
                return nil
            }

            if course.scheduleType == .ended {
                if let endDate = course.endDate {
                    let formattedDate = FormatterHelper.dateStringWithDayMonthAndYear(endDate)
                    return String(
                        format: NSLocalizedString("CourseInfoPaymentsNotAvailableEnded", comment: ""),
                        arguments: [formattedDate]
                    )
                }
                return NSLocalizedString("CourseInfoPaymentsNotAvailableEndedOther", comment: "")
            }

            if course.isPaid && !course.isPurchased && !course.canBeBought {
                return NSLocalizedString("CourseInfoPaymentsCantBeBought", comment: "")
            }

            return shouldCheckIAPPurchaseSupport && !isSupportedIAPPurchase
                ? NSLocalizedString("CourseInfoPaymentsIAPUnsupported", comment: "")
                : nil
        }()

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
            isWishlisted: course.isInWishlist,
            isWishlistAvailable: isWishlistAvailable,
            isTryForFreeAvailable: isTryForFreeAvailable,
            isRevenueAvailable: isCourseRevenueAvailable && course.canViewRevenue,
            isRestorePurchaseAvailable: isRestorePurchaseAvailable,
            purchaseFeedbackText: purchaseFeedbackText,
            buttonDescription: self.makeButtonDescription(
                course: course,
                coursePurchaseFlow: coursePurchaseFlow,
                promoCode: promoCode,
                mobileTier: mobileTier,
                shouldCheckIAPPurchaseSupport: shouldCheckIAPPurchaseSupport,
                isSupportedIAPPurchase: isSupportedIAPPurchase
            )
        )
    }

    private func makeButtonDescription(
        course: Course,
        coursePurchaseFlow: CoursePurchaseFlowType,
        promoCode: PromoCode?,
        mobileTier: MobileTierPlainObject?,
        shouldCheckIAPPurchaseSupport: Bool,
        isSupportedIAPPurchase: Bool
    ) -> CourseInfoHeaderViewModel.ButtonDescription {
        let isEnrolled = course.enrolled
        var isEnabled = isEnrolled ? course.canContinue : true
        let isNotPurchased = course.isPaid && !course.isPurchased
        var isPromo = false
        var isWishlist = false

        let title: String = {
            if isEnrolled {
                return NSLocalizedString("WidgetButtonLearn", comment: "")
            }

            if course.scheduleType == .ended {
                isWishlist = true
                return course.isInWishlist
                    ? NSLocalizedString("CourseInfoPurchaseModalWishlistButtonInWishlistTitle", comment: "")
                    : NSLocalizedString("CourseInfoPurchaseModalWishlistButtonAddToWishlistTitle", comment: "")
            }

            if isNotPurchased {
                if !course.canBeBought || (shouldCheckIAPPurchaseSupport && !isSupportedIAPPurchase) {
                    isWishlist = true
                    return course.isInWishlist
                        ? NSLocalizedString("CourseInfoPurchaseModalWishlistButtonInWishlistTitle", comment: "")
                        : NSLocalizedString("CourseInfoPurchaseModalWishlistButtonAddToWishlistTitle", comment: "")
                }

                let displayPrice: String?

                switch coursePurchaseFlow {
                case .web:
                    if let displayPriceIAP = course.displayPriceIAP {
                        displayPrice = displayPriceIAP
                    } else if let promoCode = promoCode {
                        displayPrice = FormatterHelper.price(promoCode.price, currencyCode: promoCode.currencyCode)
                        isPromo = true
                    } else {
                        displayPrice = course.displayPrice
                    }
                case .iap:
                    if let promoTierDisplayPrice = mobileTier?.promoTierDisplayPrice {
                        displayPrice = promoTierDisplayPrice
                        isPromo = true
                    } else if let priceTierDisplayPrice = mobileTier?.priceTierDisplayPrice {
                        displayPrice = priceTierDisplayPrice
                    } else {
                        displayPrice = course.displayPrice
                    }
                }

                if let displayPrice = displayPrice {
                    return String(format: NSLocalizedString("WidgetButtonBuy", comment: ""), displayPrice)
                }
            }

            return NSLocalizedString("WidgetButtonJoin", comment: "")
        }()

        let subtitle: String? = {
            if shouldCheckIAPPurchaseSupport && !isSupportedIAPPurchase {
                return nil
            }

            guard isNotPurchased && isPromo else {
                return nil
            }

            switch coursePurchaseFlow {
            case .web:
                return course.displayPrice
            case .iap:
                return mobileTier?.priceTierDisplayPrice ?? course.displayPrice
            }
        }()

        if isWishlist {
            isEnabled = !course.isInWishlist
        }

        return CourseInfoHeaderViewModel.ButtonDescription(
            title: title,
            subtitle: subtitle,
            isCallToAction: !isEnrolled,
            isEnabled: isEnabled,
            isPromo: isPromo,
            isWishlist: isWishlist
        )
    }
}
