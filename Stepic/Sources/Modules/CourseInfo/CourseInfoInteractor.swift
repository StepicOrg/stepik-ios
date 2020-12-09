import Foundation
import PromiseKit

protocol CourseInfoInteractorProtocol {
    func doCourseRefresh(request: CourseInfo.CourseLoad.Request)
    func doCourseShareAction(request: CourseInfo.CourseShareAction.Request)
    func doCourseUnenrollmentAction(request: CourseInfo.CourseUnenrollmentAction.Request)
    func doCourseFavoriteAction(request: CourseInfo.CourseFavoriteAction.Request)
    func doCourseArchiveAction(request: CourseInfo.CourseArchiveAction.Request)
    func doMainCourseAction(request: CourseInfo.MainCourseAction.Request)
    func doPreviewLessonPresentation(request: CourseInfo.PreviewLessonPresentation.Request)
    func doOnlineModeReset(request: CourseInfo.OnlineModeReset.Request)
    func doRegistrationForRemoteNotifications(request: CourseInfo.RemoteNotificationsRegistration.Request)
    func doSubmoduleControllerAppearanceUpdate(request: CourseInfo.SubmoduleAppearanceUpdate.Request)
    func doSubmodulesRegistration(request: CourseInfo.SubmoduleRegistration.Request)
    func doIAPReceiptValidation(request: CourseInfo.IAPReceiptValidationRetry.Request)
}

final class CourseInfoInteractor: CourseInfoInteractorProtocol {
    private let presenter: CourseInfoPresenterProtocol
    private let provider: CourseInfoProviderProtocol
    private let networkReachabilityService: NetworkReachabilityServiceProtocol
    private let courseSubscriber: CourseSubscriberProtocol
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

    private let dataBackUpdateService: DataBackUpdateServiceProtocol

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
    private var currentCourseIAPLocalizedPrice: String?

    private var courseWebURLPath: String? {
        guard let course = self.currentCourse else {
            return nil
        }

        if let slug = course.slug {
            return self.urlFactory.makeCourse(slug: slug)?.absoluteString
        } else {
            return self.urlFactory.makeCourse(id: course.id)?.absoluteString
        }
    }

    private var courseWebSyllabusURLPath: String? {
        guard let path = self.courseWebURLPath else {
            return nil
        }
        return "\(path)/syllabus"
    }

    // Tab index -> Submodule
    private var submodules: [Int: CourseInfoSubmoduleProtocol] = [:]

    private var isOnline = false
    private var didLoadFromCache = false

    // To fetch only one course concurrently
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.CourseInfoInteractor.CourseFetch"
    )

    init(
        courseID: Course.IdType,
        presenter: CourseInfoPresenterProtocol,
        provider: CourseInfoProviderProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol,
        courseSubscriber: CourseSubscriberProtocol,
        userAccountService: UserAccountServiceProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        notificationSuggestionManager: NotificationSuggestionManager,
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        spotlightIndexingService: SpotlightIndexingServiceProtocol,
        visitedCourseListPersistenceService: VisitedCourseListPersistenceServiceProtocol,
        urlFactory: StepikURLFactory,
        dataBackUpdateService: DataBackUpdateServiceProtocol,
        iapService: IAPServiceProtocol,
        analytics: Analytics,
        courseViewSource: AnalyticsEvent.CourseViewSource
    ) {
        self.presenter = presenter
        self.provider = provider
        self.networkReachabilityService = networkReachabilityService
        self.courseSubscriber = courseSubscriber
        self.userAccountService = userAccountService
        self.adaptiveStorageManager = adaptiveStorageManager
        self.notificationSuggestionManager = notificationSuggestionManager
        self.notificationsRegistrationService = notificationsRegistrationService
        self.spotlightIndexingService = spotlightIndexingService
        self.visitedCourseListPersistenceService = visitedCourseListPersistenceService
        self.urlFactory = urlFactory
        self.dataBackUpdateService = dataBackUpdateService
        self.iapService = iapService
        self.analytics = analytics

        self.courseID = courseID
        self.courseViewSource = courseViewSource
    }

    func doCourseRefresh(request: CourseInfo.CourseLoad.Request) {
        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()
            strongSelf.fetchCourseInAppropriateMode().done { response in
                DispatchQueue.main.async { [weak self] in
                    self?.presenter.presentCourse(response: response)
                }
            }.ensure {
                strongSelf.fetchSemaphore.signal()
            }.catch { error in
                print("course info interactor: course refresh error = \(error)")
            }
        }
    }

    func doOnlineModeReset(request: CourseInfo.OnlineModeReset.Request) {
        if self.isOnline {
            return
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
        if let urlPath = self.courseWebURLPath {
            self.analytics.send(.shareCourseTapped)
            self.presenter.presentCourseSharing(response: .init(urlPath: urlPath))
        }
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
        if let currentCourse = self.currentCourse, currentCourse.enrolled {
            self.doUserCourseAction(currentCourse.isFavorite ? .favoriteRemove : .favoriteAdd)
        }
    }

    func doCourseArchiveAction(request: CourseInfo.CourseArchiveAction.Request) {
        if let currentCourse = self.currentCourse, currentCourse.enrolled {
            self.doUserCourseAction(currentCourse.isArchived ? .archiveRemove : .archiveAdd)
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
                    )
                )
            )
        } else {
            // Paid course -> open web page
            if course.isPaid && !course.isPurchased {
                self.analytics.send(.courseBuyPressed(source: .courseScreen, id: course.id))

                if self.iapService.canBuyCourse(course) {
                    self.iapService.buy(course: course, delegate: self)
                } else {
                    self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
                    self.presenter.presentPaidCourseBuying(
                        response: .init(course: course, courseViewSource: self.courseViewSource)
                    )
                }
                return
            }

            self.analytics.send(.authorizedUserTappedJoinCourse)
            // Unenrolled course -> join, open last step
            self.courseSubscriber.join(course: course, source: .preview).done { course in
                // Refresh course
                self.currentCourse = course
                self.presenter.presentCourse(response: .init(result: .success(self.makeCourseData())))

                // Present step
                self.presenter.presentLastStep(
                    response: .init(
                        course: course,
                        isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(
                            courseId: course.id
                        )
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
        if let previewLessonID = self.currentCourse?.previewLessonID {
            self.presenter.presentPreviewLesson(response: .init(previewLessonID: previewLessonID))
        }
    }

    func doIAPReceiptValidation(request: CourseInfo.IAPReceiptValidationRetry.Request) {
        if let course = self.currentCourse {
            self.iapService.retryValidateReceipt(course: course, delegate: self)
        }
    }

    // MARK: Private methods

    private func makeCourseData() -> CourseInfo.CourseLoad.Response.Data {
        .init(course: self.currentCourse.require(), iapLocalizedPrice: self.currentCourseIAPLocalizedPrice)
    }

    private func fetchCourseInAppropriateMode() -> Promise<CourseInfo.CourseLoad.Response> {
        Promise { seal in
            firstly {
                self.isOnline && self.didLoadFromCache
                    ? self.provider.fetchRemote()
                    : self.provider.fetchCached()
            }.done { course in
                self.currentCourse = course

                if let currentCourse = self.currentCourse {
                    DispatchQueue.main.async {
                        self.visitedCourseListPersistenceService.insert(course: currentCourse)
                        self.dataBackUpdateService.triggerVisitedCourseListUpdate()
                    }

                    seal.fulfill(.init(result: .success(self.makeCourseData())))
                } else {
                    // Offline mode: present empty state only if get nil from network
                    if self.isOnline && self.didLoadFromCache {
                        seal.reject(Error.networkFetchFailed)
                    } else {
                        seal.fulfill(.init(result: .failure(Error.cachedFetchFailed)))
                    }
                }

                if let course = course,
                   course.isPaid && self.iapService.canBuyCourse(course) && self.currentCourseIAPLocalizedPrice == nil {
                    self.iapService.getLocalizedPrice(for: course).done { localizedPrice in
                        self.currentCourseIAPLocalizedPrice = localizedPrice
                        DispatchQueue.main.async {
                            self.presenter.presentCourse(response: .init(result: .success(self.makeCourseData())))
                        }
                    }
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

    private func pushCurrentCourseToSubmodules(submodules: [CourseInfoSubmoduleProtocol]) {
        if let course = self.currentCourse {
            submodules.forEach { $0.update(with: course, viewSource: self.courseViewSource, isOnline: self.isOnline) }
        }
    }

    private func doUserCourseAction(_ action: CourseInfo.UserCourseAction) {
        let currentCourse = self.currentCourse.require()

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        firstly {
            self.provider
                .fetchUserCourse(courseID: currentCourse.id)
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

            return self.provider.updateUserCourse(userCourse: userCourse)
        }.done { userCourse in
            if currentCourse.isFavorite != userCourse.isFavorite {
                currentCourse.isFavorite = userCourse.isFavorite
                self.dataBackUpdateService.triggerCourseIsFavoriteUpdate(retrievedCourse: currentCourse)
            }
            if currentCourse.isArchived != userCourse.isArchived {
                currentCourse.isArchived = userCourse.isArchived
                self.dataBackUpdateService.triggerCourseIsArchivedUpdate(retrievedCourse: currentCourse)
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

// MARK: - CourseInfoInteractor: CourseInfoTabSyllabusOutputProtocol -

extension CourseInfoInteractor: CourseInfoTabSyllabusOutputProtocol {
    func presentLesson(in unit: Unit) {
        self.presenter.presentLesson(
            response: CourseInfo.LessonPresentation.Response(unitID: unit.id)
        )
    }

    func presentPersonalDeadlinesCreation(for course: Course) {
        self.presenter.presentPersonalDeadlinesSettings(
            response: .init(action: .create, course: course)
        )
    }

    func presentPersonalDeadlinesSettings(for course: Course) {
        self.presenter.presentPersonalDeadlinesSettings(
            response: .init(action: .edit, course: course)
        )
    }

    func presentExamLesson() {
        guard let urlPath = self.courseWebSyllabusURLPath else {
            return
        }

        self.presenter.presentExamLesson(
            response: .init(urlPath: urlPath)
        )
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
        self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
        self.doCourseRefresh(request: .init())
    }

    func iapService(
        _ service: IAPServiceProtocol,
        didFailPurchaseCourse courseID: Course.IdType,
        withError error: Swift.Error
    ) {
        self.presenter.presentWaitingState(response: .init(shouldDismiss: true))

        guard let course = self.currentCourse else {
            return
        }

        if let iapServiceError = error as? IAPService.Error {
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
}
