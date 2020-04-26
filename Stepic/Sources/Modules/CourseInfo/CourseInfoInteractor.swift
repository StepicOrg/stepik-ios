import Foundation
import PromiseKit

protocol CourseInfoInteractorProtocol {
    func doCourseRefresh(request: CourseInfo.CourseLoad.Request)
    func doCourseShareAction(request: CourseInfo.CourseShareAction.Request)
    func doCourseUnenrollmentAction(request: CourseInfo.CourseUnenrollmentAction.Request)
    func doCourseFavoriteAction(request: CourseInfo.CourseFavoriteAction.Request)
    func doCourseArchiveAction(request: CourseInfo.CourseArchiveAction.Request)
    func doMainCourseAction(request: CourseInfo.MainCourseAction.Request)
    func doOnlineModeReset(request: CourseInfo.OnlineModeReset.Request)
    func doRegistrationForRemoteNotifications(request: CourseInfo.RemoteNotificationsRegistration.Request)
    func doSubmoduleControllerAppearanceUpdate(request: CourseInfo.SubmoduleAppearanceUpdate.Request)
    func doSubmodulesRegistration(request: CourseInfo.SubmoduleRegistration.Request)
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

    private var courseWebURLPath: String? {
        guard let course = self.currentCourse else {
            return nil
        }

        if let slug = course.slug {
            return "\(StepikApplicationsInfo.stepikURL)/course/\(slug)"
        } else {
            return "\(StepikApplicationsInfo.stepikURL)/\(course.id)"
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
        spotlightIndexingService: SpotlightIndexingServiceProtocol
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

        self.courseID = courseID
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
        guard let urlPath = self.courseWebURLPath else {
            return
        }
        self.presenter.presentCourseSharing(response: .init(urlPath: urlPath))
    }

    func doCourseUnenrollmentAction(request: CourseInfo.CourseUnenrollmentAction.Request) {
        guard let course = self.currentCourse, course.enrolled else {
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))
        self.courseSubscriber.leave(course: course, source: .preview).done { course in
            // Refresh course
            self.currentCourse = course
            self.presenter.presentCourse(response: .init(result: .success(course)))
        }.ensure {
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
        }.catch { error in
            print("course info interactor: drop course error = \(error)")
        }
    }

    func doCourseFavoriteAction(request: CourseInfo.CourseFavoriteAction.Request) {
        self.doUserCourseUpdateAction { $0.isFavorite.toggle() }
    }

    func doCourseArchiveAction(request: CourseInfo.CourseArchiveAction.Request) {
        self.doUserCourseUpdateAction { $0.isArchived.toggle() }
    }

    func doMainCourseAction(request: CourseInfo.MainCourseAction.Request) {
        guard let course = self.currentCourse else {
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        if !self.userAccountService.isAuthorized {
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
            if course.isPaid {
                // FIXME: analytics dependency
                AmplitudeAnalyticsEvents.Course.buyPressed(source: .courseScreen, courseID: course.id).send()
                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
                self.presenter.presentPaidCourseBuying(response: .init(course: course))
                return
            }

            // Unenrolled course -> join, open last step
            self.courseSubscriber.join(course: course, source: .preview).done { course in
                // Refresh course
                self.currentCourse = course
                self.presenter.presentCourse(response: .init(result: .success(course)))

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

    // MARK: Private methods

    private func fetchCourseInAppropriateMode() -> Promise<CourseInfo.CourseLoad.Response> {
        Promise { seal in
            firstly {
                self.isOnline && self.didLoadFromCache
                    ? self.provider.fetchRemote()
                    : self.provider.fetchCached()
            }.done { course in
                self.currentCourse = course

                if let targetCourse = self.currentCourse {
                    seal.fulfill(.init(result: .success(targetCourse)))
                } else {
                    // Offline mode: present empty state only if get nil from network
                    if self.isOnline && self.didLoadFromCache {
                        seal.reject(Error.networkFetchFailed)
                    } else {
                        seal.fulfill(.init(result: .failure(Error.cachedFetchFailed)))
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
            submodules.forEach { $0.update(with: course, isOnline: self.isOnline) }
        }
    }

    private func doUserCourseUpdateAction(_ updateBlock: @escaping (UserCourse) -> Void) {
        guard let course = self.currentCourse, course.enrolled else {
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        firstly {
            self.provider
                .fetchUserCourse(courseID: course.id)
                .compactMap { $0 }
        }.then { userCourse -> Promise<UserCourse> in
            updateBlock(userCourse)
            return self.provider.updateUserCourse(userCourse: userCourse)
        }.done { userCourse in
            if let course = self.currentCourse {
                course.isFavorite = userCourse.isFavorite
                course.isArchived = userCourse.isArchived
                self.presenter.presentCourse(response: .init(result: .success(course)))
            }
            self.presenter.presentWaitingStatus(response: .init(isSuccessful: true))
        }.catch { error in
            print("course info interactor: user course action error = \(error)")
            self.presenter.presentWaitingStatus(response: .init(isSuccessful: false))
        }
    }

    enum Error: Swift.Error {
        case cachedFetchFailed
        case networkFetchFailed
    }
}

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
