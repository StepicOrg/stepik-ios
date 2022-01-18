import Foundation
import PromiseKit
import StoreKit

// swiftlint:disable file_length
protocol CourseInfoInteractorProtocol {
    func doCourseRefresh(request: CourseInfo.CourseLoad.Request)
    func doCourseShareAction(request: CourseInfo.CourseShareAction.Request)
    func doCourseUnenrollmentAction(request: CourseInfo.CourseUnenrollmentAction.Request)
    func doCourseFavoriteAction(request: CourseInfo.CourseFavoriteAction.Request)
    func doCourseArchiveAction(request: CourseInfo.CourseArchiveAction.Request)
    func doCourseContentSearchPresentation(request: CourseInfo.CourseContentSearchPresentation.Request)
    func doWishlistMainAction(request: CourseInfo.CourseWishlistMainAction.Request)
    func doMainCourseAction(request: CourseInfo.MainCourseAction.Request)
    func doPreviewLessonPresentation(request: CourseInfo.PreviewLessonPresentation.Request)
    func doCourseRevenuePresentation(request: CourseInfo.CourseRevenuePresentation.Request)
    func doOnlineModeReset(request: CourseInfo.OnlineModeReset.Request)
    func doRegistrationForRemoteNotifications(request: CourseInfo.RemoteNotificationsRegistration.Request)
    func doSubmoduleControllerAppearanceUpdate(request: CourseInfo.SubmoduleAppearanceUpdate.Request)
    func doSubmodulesRegistration(request: CourseInfo.SubmoduleRegistration.Request)
    func doIAPReceiptValidationRetry(request: CourseInfo.IAPReceiptValidationRetry.Request)
    func doRestorePurchase(request: CourseInfo.PaidCourseRestorePurchase.Request)
    func doPurchaseCourseNotificationUpdate(request: CourseInfo.PurchaseNotificationUpdate.Request)
}

final class CourseInfoInteractor: CourseInfoInteractorProtocol {
    private let presenter: CourseInfoPresenterProtocol
    private let provider: CourseInfoProviderProtocol
    private let networkReachabilityService: NetworkReachabilityServiceProtocol
    private let courseSubscriber: CourseSubscriberProtocol
    private let coursePurchaseReminder: CoursePurchaseReminderProtocol
    private let userAccountService: UserAccountServiceProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    private let notificationSuggestionManager: NotificationSuggestionManager
    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    private let spotlightIndexingService: SpotlightIndexingServiceProtocol
    private let visitedCourseListPersistenceService: VisitedCourseListPersistenceServiceProtocol
    private let urlFactory: StepikURLFactory
    private let analytics: Analytics
    private let courseViewSource: AnalyticsEvent.CourseViewSource

    private let iapService: IAPServiceProtocol
    private let iapPaymentsCache: IAPPaymentsCacheProtocol

    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    private let remoteConfig: RemoteConfig

    private let courseID: Course.IdType
    private var currentCourse: Course? {
        didSet {
            if let course = self.currentCourse {
                LastStepGlobalContext.context.course = course
                self.spotlightIndexingService.indexCourses([course])
            }

            self.pushCurrentCourseToSubmodules(submodules: Array(self.submodules.values))
        }
    }

    private var promoCodeName: String?
    private var currentPromoCode: PromoCode?

    private var currentMobileTier: MobileTierPlainObject?
    private var isRestorePurchaseInProgress = false

    private var shouldCheckIAPPurchaseSupport: Bool {
        (self.currentCourse?.isPaid ?? false) && self.remoteConfig.coursePurchaseFlow == .iap
    }
    private var isSupportedIAPPurchase: Bool {
        self.shouldCheckIAPPurchaseSupport && self.currentMobileTier?.priceTier != nil
    }

    private var courseWebURL: URL? {
        guard let course = self.currentCourse else {
            return nil
        }

        if let slug = course.slug {
            return self.urlFactory.makeCourse(slug: slug)
        } else {
            return self.urlFactory.makeCourse(id: course.id)
        }
    }

    private var courseWebSyllabusURLPath: String? {
        guard let courseWebURLPath = self.courseWebURL?.absoluteString else {
            return nil
        }
        return "\(courseWebURLPath)/syllabus"
    }

    // Tab index -> Submodule
    private var submodules: [Int: CourseInfoSubmoduleProtocol] = [:]

    private var isOnline = false
    private var didLoadFromCache = false
    private var shouldOpenedAnalyticsEventSend = true

    private var onNetworkReachabilityStatusChangeCallback: ((NetworkReachabilityStatus) -> Void)?

    // To fetch only one course concurrently
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.CourseInfoInteractor.CourseFetch"
    )

    init(
        courseID: Course.IdType,
        promoCodeName: String?,
        presenter: CourseInfoPresenterProtocol,
        provider: CourseInfoProviderProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol,
        courseSubscriber: CourseSubscriberProtocol,
        coursePurchaseReminder: CoursePurchaseReminderProtocol,
        userAccountService: UserAccountServiceProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        notificationSuggestionManager: NotificationSuggestionManager,
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        spotlightIndexingService: SpotlightIndexingServiceProtocol,
        visitedCourseListPersistenceService: VisitedCourseListPersistenceServiceProtocol,
        urlFactory: StepikURLFactory,
        dataBackUpdateService: DataBackUpdateServiceProtocol,
        iapService: IAPServiceProtocol,
        iapPaymentsCache: IAPPaymentsCacheProtocol,
        analytics: Analytics,
        remoteConfig: RemoteConfig,
        courseViewSource: AnalyticsEvent.CourseViewSource
    ) {
        self.presenter = presenter
        self.provider = provider
        self.networkReachabilityService = networkReachabilityService
        self.courseSubscriber = courseSubscriber
        self.coursePurchaseReminder = coursePurchaseReminder
        self.userAccountService = userAccountService
        self.adaptiveStorageManager = adaptiveStorageManager
        self.notificationSuggestionManager = notificationSuggestionManager
        self.notificationsRegistrationService = notificationsRegistrationService
        self.spotlightIndexingService = spotlightIndexingService
        self.visitedCourseListPersistenceService = visitedCourseListPersistenceService
        self.urlFactory = urlFactory
        self.dataBackUpdateService = dataBackUpdateService
        self.iapService = iapService
        self.iapPaymentsCache = iapPaymentsCache
        self.analytics = analytics
        self.remoteConfig = remoteConfig

        self.courseID = courseID
        self.promoCodeName = promoCodeName
        self.courseViewSource = courseViewSource
    }

    func doCourseRefresh(request: CourseInfo.CourseLoad.Request) {
        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()
            strongSelf.sendOpenedAnalyticsEvents()

            strongSelf.fetchCourseInAppropriateMode().done { response in
                DispatchQueue.main.async { [weak self] in
                    if case .success = response.result {
                        self?.presenter.presentCourse(response: response)
                    }
                }
            }.ensure {
                strongSelf.fetchSemaphore.signal()
            }.catch { error in
                print("course info interactor: course refresh error = \(error)")

                DispatchQueue.main.async {
                    self?.presenter.presentCourse(response: .init(result: .failure(error)))
                }
            }
        }
    }

    func doOnlineModeReset(request: CourseInfo.OnlineModeReset.Request) {
        if self.isOnline {
            return
        }

        if self.onNetworkReachabilityStatusChangeCallback == nil {
            self.onNetworkReachabilityStatusChangeCallback = { [weak self] _ in
                self?.doOnlineModeReset(request: .init())
            }
            self.networkReachabilityService.startListening(
                onUpdatePerforming: self.onNetworkReachabilityStatusChangeCallback.require()
            )
        }

        if self.networkReachabilityService.isReachable {
            self.isOnline = true
            self.doCourseRefresh(request: .init())
        }
    }

    func doSubmoduleControllerAppearanceUpdate(request: CourseInfo.SubmoduleAppearanceUpdate.Request) {
        self.submodules[request.submoduleIndex]?.handleControllerAppearance()
    }

    func doRegistrationForRemoteNotifications(request: CourseInfo.RemoteNotificationsRegistration.Request) {
        self.notificationsRegistrationService.registerForRemoteNotifications()
    }

    func doSubmodulesRegistration(request: CourseInfo.SubmoduleRegistration.Request) {
        for (key, value) in request.submodules {
            self.submodules[key] = value
        }
        self.pushCurrentCourseToSubmodules(submodules: Array(self.submodules.values))
    }

    func doCourseShareAction(request: CourseInfo.CourseShareAction.Request) {
        guard let courseWebURL = self.courseWebURL else {
            return
        }

        self.analytics.send(.shareCourseTapped)
        self.presenter.presentCourseSharing(response: .init(url: courseWebURL, courseViewSource: self.courseViewSource))
    }

    func doCourseUnenrollmentAction(request: CourseInfo.CourseUnenrollmentAction.Request) {
        guard let course = self.currentCourse, course.enrolled else {
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))
        self.courseSubscriber.leave(course: course, source: .preview).done { course in
            // Refresh course
            self.currentCourse = course
            self.presenter.presentCourse(response: .init(result: .success(self.makeCourseData())))
        }.ensure {
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
        }.catch { error in
            print("course info interactor: drop course error = \(error)")
        }
    }

    func doCourseFavoriteAction(request: CourseInfo.CourseFavoriteAction.Request) {
        if let course = self.currentCourse, course.enrolled {
            self.doUserCourseAction(course: course, action: course.isFavorite ? .favoriteRemove : .favoriteAdd)
        }
    }

    func doCourseArchiveAction(request: CourseInfo.CourseArchiveAction.Request) {
        if let course = self.currentCourse, course.enrolled {
            self.doUserCourseAction(course: course, action: course.isArchived ? .archiveRemove : .archiveAdd)
        }
    }

    func doCourseContentSearchPresentation(request: CourseInfo.CourseContentSearchPresentation.Request) {
        self.presenter.presentCourseContentSearch(response: .init(courseID: self.courseID))
    }

    func doWishlistMainAction(request: CourseInfo.CourseWishlistMainAction.Request) {
        guard let course = self.currentCourse else {
            return
        }

        let targetAction = course.isInWishlist
            ? CourseInfo.CourseWishlistAction.remove
            : CourseInfo.CourseWishlistAction.add

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        firstly { () -> Promise<Void> in
            switch targetAction {
            case .add:
                self.analytics.send(
                    .wishlistCourseAdded(
                        id: course.id,
                        title: course.title,
                        isPaid: course.isPaid,
                        viewSource: self.courseViewSource
                    )
                )
                return self.provider.addCourseToWishlist()
            case .remove:
                self.analytics.send(
                    .wishlistCourseRemoved(
                        id: course.id,
                        title: course.title,
                        isPaid: course.isPaid,
                        viewSource: self.courseViewSource
                    )
                )
                return self.provider.deleteCourseFromWishlist()
            }
        }.done {
            self.presenter.presentCourse(response: .init(result: .success(self.makeCourseData())))
            self.presenter.presentWishlistMainActionResult(response: .init(action: targetAction, isSuccessful: true))
        }.catch { _ in
            self.presenter.presentWishlistMainActionResult(response: .init(action: targetAction, isSuccessful: false))
        }
    }

    func doMainCourseAction(request: CourseInfo.MainCourseAction.Request) {
        guard let course = self.currentCourse else {
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        if !self.userAccountService.isAuthorized {
            self.analytics.send(.anonymousUserTappedJoinCourse)
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            self.presenter.presentAuthorization(response: .init())
            return
        }

        if course.enrolled {
            // Enrolled course -> open last step
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            self.presenter.presentLastStep(
                response: .init(
                    course: course,
                    isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(
                        courseId: course.id
                    ),
                    courseViewSource: self.courseViewSource
                )
            )
        } else {
            // Paid course -> buy course or wishlist main action
            if course.isPaid && !course.isPurchased {
                if self.shouldCheckIAPPurchaseSupport && !self.isSupportedIAPPurchase {
                    return self.doWishlistMainAction(request: .init())
                }

                self.analytics.send(
                    .buyCoursePressed(id: course.id),
                    .courseBuyPressed(
                        id: course.id,
                        source: request.courseBuySource,
                        isWishlisted: course.isInWishlist,
                        promoCode: self.promoCodeName
                    )
                )

                switch self.remoteConfig.coursePurchaseFlow {
                case .web:
                    if self.iapService.canBuyCourse(course) {
                        self.iapService.buy(course: course, delegate: self)
                    } else {
                        self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
                        self.presenter.presentPaidCourseBuying(
                            response: .init(course: course, courseViewSource: self.courseViewSource)
                        )
                    }
                case .iap:
                    self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
                    self.presenter.presentPaidCoursePurchaseModal(
                        response: .init(
                            courseID: self.courseID,
                            promoCodeName: self.promoCodeName,
                            mobileTierID: self.currentMobileTier?.id,
                            courseBuySource: request.courseBuySource
                        )
                    )
                }

                return self.coursePurchaseReminder.createPurchaseNotification(for: course)
            }

            self.analytics.send(.authorizedUserTappedJoinCourse)
            // Unenrolled course -> join, open last step
            self.courseSubscriber.join(course: course, source: .preview).done { course in
                // Refresh course
                self.currentCourse = course
                self.presenter.presentCourse(response: .init(result: .success(self.makeCourseData())))

                // Remove course from wishlist
                if course.isInWishlist {
                    self.provider.deleteCourseFromWishlist().cauterize()
                }

                // Present step
                self.presenter.presentLastStep(
                    response: .init(
                        course: course,
                        isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(
                            courseId: course.id
                        ),
                        courseViewSource: self.courseViewSource
                    )
                )
            }.ensure {
                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            }.catch { error in
                print("course info interactor: join course error = \(error)")
            }
        }
    }

    func doPreviewLessonPresentation(request: CourseInfo.PreviewLessonPresentation.Request) {
        guard let currentCourse = self.currentCourse,
              let previewLessonID = currentCourse.previewLessonID else {
            return
        }

        self.presenter.presentPreviewLesson(
            response: .init(
                previewLessonID: previewLessonID,
                previewUnitID: currentCourse.previewUnitID,
                promoCodeName: self.promoCodeName
            )
        )
    }

    func doCourseRevenuePresentation(request: CourseInfo.CourseRevenuePresentation.Request) {
        self.presenter.presentCourseRevenue(response: .init(courseID: self.courseID))
    }

    func doIAPReceiptValidationRetry(request: CourseInfo.IAPReceiptValidationRetry.Request) {
        if let course = self.currentCourse {
            self.iapService.retryValidateReceipt(course: course, delegate: self)
        }
    }

    func doRestorePurchase(request: CourseInfo.PaidCourseRestorePurchase.Request) {
        if self.isRestorePurchaseInProgress {
            return
        }
        self.isRestorePurchaseInProgress = true

        self.presenter.presentPaidCourseRestorePurchaseResult(response: .init(state: .inProgress))
        self.analytics.send(.courseRestoreCoursePurchasePressed(id: self.courseID, source: .courseScreen))

        firstly { () -> Guarantee<MobileTierPlainObject?> in
            if let currentMobileTier = self.currentMobileTier {
                return .value(currentMobileTier)
            } else if let course = self.currentCourse {
                return self.fetchMobileTier(
                    course: course,
                    dataSourceType: .remote
                ).then { mobileTierOrNil -> Guarantee<MobileTierPlainObject?> in
                    if let mobileTier = mobileTierOrNil {
                        self.currentMobileTier = mobileTier
                    }
                    return .value(mobileTierOrNil)
                }
            }
            return .value(nil)
        }
        .compactMap { $0?.promoTier ?? $0?.priceTier }
        .done { purchaseMobileTier in
            if self.iapPaymentsCache.getCoursePayment(for: self.courseID) == nil {
                self.iapService
                    .fetchProduct(for: purchaseMobileTier)
                    .compactMap { $0 }
                    .done { product in
                        self.iapPaymentsCache.insertCoursePayment(
                            courseID: self.courseID,
                            promoCode: self.currentMobileTier?.promoCodeName,
                            product: product
                        )
                        self.iapService.retryValidateReceipt(
                            courseID: self.courseID,
                            mobileTier: purchaseMobileTier,
                            delegate: self
                        )
                    }
                    .catch { error in
                        self.iapService(self.iapService, didFailPurchaseCourse: self.courseID, withError: error)
                    }
            } else {
                self.iapService.retryValidateReceipt(
                    courseID: self.courseID,
                    mobileTier: purchaseMobileTier,
                    delegate: self
                )
            }
        }
        .catch { error in
            self.iapService(self.iapService, didFailPurchaseCourse: self.courseID, withError: error)
        }
    }

    func doPurchaseCourseNotificationUpdate(request: CourseInfo.PurchaseNotificationUpdate.Request) {
        self.coursePurchaseReminder.updatePurchaseNotification(for: self.courseID)
    }

    // MARK: Private methods

    private func sendOpenedAnalyticsEvents() {
        guard self.shouldOpenedAnalyticsEventSend else {
            return
        }

        self.shouldOpenedAnalyticsEventSend = false
        self.analytics.send(.catalogClick(courseID: self.courseID, viewSource: self.courseViewSource))
    }

    private func makeCourseData() -> CourseInfo.CourseLoad.Response.Data {
        .init(
            course: self.currentCourse.require(),
            isWishlistAvailable: self.userAccountService.isAuthorized && !self.currentCourse.require().enrolled,
            isCourseRevenueAvailable: self.remoteConfig.isCourseRevenueAvailable,
            coursePurchaseFlow: self.remoteConfig.coursePurchaseFlow,
            promoCode: self.currentPromoCode,
            mobileTier: self.currentMobileTier,
            shouldCheckIAPPurchaseSupport: self.shouldCheckIAPPurchaseSupport,
            isSupportedIAPPurchase: self.isSupportedIAPPurchase,
            isRestorePurchaseAvailable: self.userAccountService.isAuthorized
                && self.remoteConfig.coursePurchaseFlow == .iap
                && self.currentCourse.require().isPaid
                && !self.currentCourse.require().isPurchased
        )
    }

    private func fetchCourseInAppropriateMode() -> Promise<CourseInfo.CourseLoad.Response> {
        let dataSourceType: DataSourceType = self.isOnline && self.didLoadFromCache ? .remote : .cache

        return Promise { seal in
            firstly { () -> Promise<Course?> in
                switch dataSourceType {
                case .cache:
                    return self.provider.fetchCached()
                case .remote:
                    return self.provider.fetchRemote()
                }
            }.then { course -> Promise<(Course?, MobileTierPlainObject?)> in
                self.fetchMobileTier(course: course, dataSourceType: dataSourceType)
                    .map { (course, $0) }
            }.done { course, mobileTier in
                self.currentCourse = course
                self.currentMobileTier = mobileTier

                let isMobileTierFetchSuccessful: Bool = {
                    switch self.remoteConfig.coursePurchaseFlow {
                    case .web:
                        return true
                    case .iap:
                        if self.currentCourse?.isPaid ?? false {
                            return self.currentMobileTier != nil
                        }
                        return true
                    }
                }()

                if let currentCourse = self.currentCourse, isMobileTierFetchSuccessful {
                    DispatchQueue.main.async {
                        self.visitedCourseListPersistenceService.insert(course: currentCourse)
                        self.dataBackUpdateService.triggerVisitedCourseListUpdate()
                    }

                    seal.fulfill(.init(result: .success(self.makeCourseData())))
                } else {
                    // Offline mode: present empty state only if get nil from network
                    switch dataSourceType {
                    case .remote:
                        seal.reject(Error.networkFetchFailed)
                    case .cache:
                        seal.fulfill(.init(result: .failure(Error.cachedFetchFailed)))
                    }
                }

                DispatchQueue.main.async {
                    self.fetchAndPresentPriceInfoIfNeeded()
                }

                if !self.didLoadFromCache {
                    self.didLoadFromCache = true
                }
            }.catch { error in
                if case CourseInfoProvider.Error.networkFetchFailed = error,
                   self.didLoadFromCache,
                   self.currentCourse != nil {
                    // Offline mode: we already presented cached course, but network request failed
                    // so let's ignore it and show only cached
                    seal.fulfill(.init(result: .failure(Error.networkFetchFailed)))
                } else {
                    seal.reject(error)
                }
            }
        }
    }

    private func fetchMobileTier(course: Course?, dataSourceType: DataSourceType) -> Guarantee<MobileTierPlainObject?> {
        guard self.remoteConfig.coursePurchaseFlow == .iap else {
            return .value(nil)
        }

        guard let course = course, course.isPaid else {
            return .value(nil)
        }

        if self.promoCodeName == nil,
           let defaultPromoCode = course.defaultPromoCode, defaultPromoCode.isValid {
            self.promoCodeName = defaultPromoCode.name
        }

        return Guarantee { seal in
            self.provider
                .fetchMobileTier(promoCodeName: self.promoCodeName, dataSourceType: dataSourceType)
                .compactMap { $0 }
                .then { self.iapService.fetchAndSetLocalizedPrices(mobileTier: $0) }
                .done { mobileTier in
                    seal(mobileTier)
                }
                .catch { _ in
                    seal(nil)
                }
        }
    }

    @available(*, deprecated, message: "Legacy purchase flow")
    private func fetchAndPresentPriceInfoIfNeeded() {
        guard let course = self.currentCourse, course.isPaid else {
            return
        }

        switch self.remoteConfig.coursePurchaseFlow {
        case .web:
            if self.iapService.canBuyCourse(course) && (course.displayPriceIAP?.isEmpty ?? true) {
                self.iapService.fetchLocalizedPrice(for: course).done { localizedPrice in
                    self.currentCourse?.displayPriceIAP = localizedPrice
                    self.presenter.presentCourse(response: .init(result: .success(self.makeCourseData())))
                }
            }

            self.fetchAndPresentPromoCodeIfNeeded()
        case .iap:
            break
        }
    }

    @available(*, deprecated, message: "Legacy purchase flow")
    private func fetchAndPresentPromoCodeIfNeeded() {
        guard self.currentPromoCode == nil,
              let course = self.currentCourse, course.isPaid else {
            return
        }

        firstly { () -> Promise<PromoCode?> in
            if let promoCodeName = self.promoCodeName {
                return self.provider.checkPromoCode(name: promoCodeName).map { $0 }
            } else if let defaultPromoCode = course.defaultPromoCode {
                return defaultPromoCode.isValid ? .value(defaultPromoCode) : .value(nil)
            } else {
                return .value(nil)
            }
        }
        .compactMap { $0 }
        .done { promoCode in
            self.currentPromoCode = promoCode
            self.presenter.presentCourse(response: .init(result: .success(self.makeCourseData())))
        }
        .cauterize()
    }

    private func pushCurrentCourseToSubmodules(submodules: [CourseInfoSubmoduleProtocol]) {
        if let course = self.currentCourse {
            submodules.forEach { $0.update(with: course, viewSource: self.courseViewSource, isOnline: self.isOnline) }
        }
    }

    private func doUserCourseAction(course: Course, action: CourseInfo.UserCourseAction) {
        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        self.analytics.send(.userCourseActionMade(action, course: course, viewSource: self.courseViewSource))

        firstly {
            self.provider
                .fetchUserCourse()
                .compactMap { $0 }
        }.then { userCourse -> Promise<UserCourse> in
            switch action {
            case .favoriteAdd:
                userCourse.isFavorite = true
            case .favoriteRemove:
                userCourse.isFavorite = false
            case .archiveAdd:
                userCourse.isArchived = true
            case .archiveRemove:
                userCourse.isArchived = false
            }

            return self.provider.updateUserCourse(userCourse)
        }.done { userCourse in
            if course.isFavorite != userCourse.isFavorite {
                course.isFavorite = userCourse.isFavorite
                self.dataBackUpdateService.triggerCourseIsFavoriteUpdate(retrievedCourse: course)
            }
            if course.isArchived != userCourse.isArchived {
                course.isArchived = userCourse.isArchived
                self.dataBackUpdateService.triggerCourseIsArchivedUpdate(retrievedCourse: course)
            }

            self.presenter.presentCourse(response: .init(result: .success(self.makeCourseData())))
            self.presenter.presentUserCourseActionResult(response: .init(userCourseAction: action, isSuccessful: true))
        }.catch { error in
            print("course info interactor: user course action error = \(error)")
            self.presenter.presentUserCourseActionResult(response: .init(userCourseAction: action, isSuccessful: false))
        }
    }

    enum Error: Swift.Error {
        case cachedFetchFailed
        case networkFetchFailed
    }
}

// MARK: - CourseInfoInteractor: CourseInfoInputProtocol -

extension CourseInfoInteractor: CourseInfoInputProtocol {}

// MARK: - CourseInfoInteractor: LessonOutputProtocol -

extension CourseInfoInteractor: LessonOutputProtocol {
    func handleLessonDidRequestBuyCourse() {
        self.presenter.presentLessonModuleBuyCourseAction(response: .init())
    }

    func handleLessonDidRequestLeaveReview() {
        self.presenter.presentLessonModuleWriteReviewAction(response: .init())
    }

    func handleLessonDidRequestPresentCatalog() {
        self.presenter.presentLessonModuleCatalogAction(response: .init())
    }
}

// MARK: - CourseInfoInteractor: CourseInfoTabSyllabusOutputProtocol -

extension CourseInfoInteractor: CourseInfoTabSyllabusOutputProtocol {
    func presentLesson(in unit: Unit) {
        self.presenter.presentLesson(response: .init(unitID: unit.id, promoCodeName: self.promoCodeName))
    }

    func presentPersonalDeadlinesCreation(for course: Course) {
        self.presenter.presentPersonalDeadlinesSettings(response: .init(action: .create, course: course))
    }

    func presentPersonalDeadlinesSettings(for course: Course) {
        self.presenter.presentPersonalDeadlinesSettings(response: .init(action: .edit, course: course))
    }

    func presentExamLesson() {
        if let courseWebSyllabusURLPath = self.courseWebSyllabusURLPath {
            self.presenter.presentExamLesson(response: .init(urlPath: courseWebSyllabusURLPath))
        }
    }
}

// MARK: - CourseInfoInteractor: NotificationsRegistrationServiceDelegate -

extension CourseInfoInteractor: NotificationsRegistrationServiceDelegate {
    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        shouldPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) -> Bool {
        self.notificationSuggestionManager.canShowAlert(context: .courseSubscription)
    }

    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        didPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) {
        if alertType == .permission {
            self.notificationSuggestionManager.didShowAlert(context: .courseSubscription)
        }
    }
}

// MARK: - CourseInfoInteractor: IAPServiceDelegate -

extension CourseInfoInteractor: IAPServiceDelegate {
    func iapService(_ service: IAPServiceProtocol, didPurchaseCourse courseID: Course.IdType) {
        self.handleDidPurchaseCourse(courseID)
    }

    func iapService(
        _ service: IAPServiceProtocol,
        didFailPurchaseCourse courseID: Course.IdType,
        withError error: Swift.Error
    ) {
        self.presenter.presentWaitingState(response: .init(shouldDismiss: true))

        guard let course = self.currentCourse, course.id == courseID else {
            return
        }

        if self.isRestorePurchaseInProgress {
            self.isRestorePurchaseInProgress = false

            if let iapServiceError = error as? IAPService.Error {
                self.analytics.send(
                    .courseBuyCourseVerificationFailure(
                        id: courseID,
                        errorType: iapServiceError.analyticsErrorType,
                        errorDescription: iapServiceError.analyticsErrorDescription
                    )
                )
            } else {
                self.analytics.send(
                    .courseBuyCourseVerificationFailure(
                        id: courseID,
                        errorType: String(describing: error),
                        errorDescription: error.localizedDescription
                    )
                )
            }

            self.presenter.presentPaidCourseRestorePurchaseResult(response: .init(state: .error(error)))
        } else if let iapServiceError = error as? IAPService.Error {
            switch iapServiceError {
            case .unsupportedCourse, .noProductIDsFound, .noProductsFound, .productsRequestFailed:
                self.presenter.presentPaidCourseBuying(
                    response: .init(course: course, courseViewSource: self.courseViewSource)
                )
            case .paymentWasCancelled:
                break
            case .paymentFailed, .paymentUserChanged:
                self.presenter.presentIAPPaymentFailed(response: .init(error: error, course: course))
            case .paymentNotAllowed:
                self.presenter.presentIAPNotAllowed(response: .init(error: error, course: course))
            case .paymentReceiptValidationFailed:
                self.presenter.presentIAPReceiptValidationFailed(response: .init(error: error, course: course))
            }
        } else {
            self.presenter.presentIAPPaymentFailed(response: .init(error: error, course: course))
        }
    }

    // MARK: Private Helpers

    private func handleDidPurchaseCourse(_ courseID: Course.IdType) {
        self.coursePurchaseReminder.removePurchaseNotification(for: courseID)

        guard self.courseID == courseID else {
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
        self.doCourseRefresh(request: .init())

        if self.currentCourse?.isInWishlist ?? false {
            self.provider.deleteCourseFromWishlist().cauterize()
        }

        if self.isRestorePurchaseInProgress {
            self.isRestorePurchaseInProgress = false

            self.analytics.send(
                .courseBuyCourseVerificationSuccess(
                    id: self.courseID,
                    source: .courseScreen,
                    isWishlisted: self.currentCourse?.isInWishlist ?? false,
                    promoCode: self.currentMobileTier?.promoTier != nil ? self.currentMobileTier?.promoCodeName : nil
                )
            )

            self.presenter.presentPaidCourseRestorePurchaseResult(response: .init(state: .success))
        }
    }
}

// MARK: - CourseInfoInteractor: CourseInfoPurchaseModalOutputProtocol -

extension CourseInfoInteractor: CourseInfoPurchaseModalOutputProtocol {
    func handleCourseInfoPurchaseModalDidAddCourseToWishlist(courseID: Course.IdType) {
        guard self.courseID == courseID else {
            return
        }

        self.presenter.presentCourse(response: .init(result: .success(self.makeCourseData())))
    }

    func handleCourseInfoPurchaseModalDidRequestStartLearning(courseID: Course.IdType) {
        guard let course = self.currentCourse,
              course.id == courseID && course.enrolled else {
            return
        }

        self.presenter.presentPurchaseModalStartLearning(
            response: .init(
                course: course,
                isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: course.id),
                courseViewSource: self.courseViewSource
            )
        )
    }

    func handleCourseInfoPurchaseModalDidPurchaseCourse(courseID: Course.IdType) {
        self.handleDidPurchaseCourse(courseID)
    }
}
