//
//  CourseInfoCourseInfoInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoInteractorProtocol {
    func refreshCourse()
    func shareCourse()
    func dropCourse()
    func doMainCourseAction()
    func tryToSetOnlineMode()
    func registerForRemoteNotifications()
    func handleControllerAppearance(request: CourseInfo.SubmoduleAppearanceHandling.Request)

    func registerSubmodules(request: CourseInfo.RegisterSubmodule.Request)
}

final class CourseInfoInteractor: CourseInfoInteractorProtocol {
    let presenter: CourseInfoPresenterProtocol
    let provider: CourseInfoProviderProtocol
    let networkReachabilityService: NetworkReachabilityServiceProtocol
    let courseSubscriber: CourseSubscriberProtocol
    let userAccountService: UserAccountServiceProtocol
    let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    let notificationSuggestionManager: NotificationSuggestionManager
    let notificationsRegistrationService: NotificationsRegistrationServiceProtocol

    private let courseID: Course.IdType
    private var currentCourse: Course? {
        didSet {
            if let course = self.currentCourse {
                LastStepGlobalContext.context.course = course
            }

            self.pushCurrentCourseToSubmodules(submodules: self.submodules)
        }
    }

    private var courseWebURLPath: String? {
        guard let course = self.currentCourse else {
            return nil
        }

        if let slug = course.slug {
            return "\(StepicApplicationsInfo.stepicURL)/course/\(slug)"
        } else {
            return "\(StepicApplicationsInfo.stepicURL)/\(course.id)"
        }
    }

    private var courseWebSyllabusURLPath: String? {
        guard let path = self.courseWebURLPath else {
            return nil
        }
        return "\(path)/syllabus"
    }

    private var submodules: [CourseInfoSubmoduleProtocol] = []

    private var isOnline = false
    private var didLoadFromCache = false

    private let fetchSemaphore = DispatchSemaphore(value: 1)

    init(
        courseID: Course.IdType,
        presenter: CourseInfoPresenterProtocol,
        provider: CourseInfoProviderProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol,
        courseSubscriber: CourseSubscriberProtocol,
        userAccountService: UserAccountServiceProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        notificationSuggestionManager: NotificationSuggestionManager,
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol

    ) {
        self.presenter = presenter
        self.provider = provider
        self.networkReachabilityService = networkReachabilityService
        self.courseSubscriber = courseSubscriber
        self.userAccountService = userAccountService
        self.adaptiveStorageManager = adaptiveStorageManager
        self.notificationSuggestionManager = notificationSuggestionManager
        self.notificationsRegistrationService = notificationsRegistrationService

        self.courseID = courseID
    }

    func refreshCourse() {
        let queue = DispatchQueue(label: String(describing: self))

        queue.async { [weak self] in
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
            }.catch { _ in
                // TODO: handle
            }
        }
    }

    func tryToSetOnlineMode() {
        if self.isOnline {
            return
        }

        if self.networkReachabilityService.isReachable {
            self.isOnline = true
            self.refreshCourse()
        }
    }

    func handleControllerAppearance(request: CourseInfo.SubmoduleAppearanceHandling.Request) {
        self.submodules[safe: request.submoduleIndex]?.handleControllerAppearance()
    }

    func registerForRemoteNotifications() {
        self.notificationsRegistrationService.registerForRemoteNotifications()
    }

    func registerSubmodules(request: CourseInfo.RegisterSubmodule.Request) {
        self.submodules = request.submodules
        self.pushCurrentCourseToSubmodules(submodules: self.submodules)
    }

    func shareCourse() {
        guard let urlPath = self.courseWebURLPath else {
            return
        }
        self.presenter.presentCourseSharing(response: .init(urlPath: urlPath))
    }

    func dropCourse() {
        guard let course = self.currentCourse, course.enrolled else {
            return
        }

        self.presenter.presentWaitingState()
        self.courseSubscriber.leave(course: course, source: .preview).done { course in
            // Refresh course
            self.currentCourse = course
            self.presenter.presentCourse(response: .init(result: .success(course)))
        }.ensure {
            self.presenter.dismissWaitingState()
        }.catch { error in
            print("course info interactor: drop course error = \(error)")
        }
    }

    func doMainCourseAction() {
        guard let course = self.currentCourse else {
            return
        }

        self.presenter.presentWaitingState()

        if !self.userAccountService.isAuthorized {
            self.presenter.dismissWaitingState()
            self.presenter.presentAuthorization()
            return
        }

        if course.enrolled {
            // Enrolled course -> open last step
            self.presenter.dismissWaitingState()
            self.presenter.presentLastStep(
                response: .init(
                    course: course,
                    isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(
                        courseId: course.id
                    )
                )
            )
        } else {
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
                self.presenter.dismissWaitingState()
            }.catch { error in
                print("course info interactor: join course error = \(error)")
            }
        }
    }

    // MARK: Private methods

    private func fetchCourseInAppropriateMode() -> Promise<CourseInfo.ShowCourse.Response> {
        return Promise { seal in
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
                        // TODO: unable to load error
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
                } else {
                    // TODO: error
                }
            }
        }
    }

    private func pushCurrentCourseToSubmodules(submodules: [CourseInfoSubmoduleProtocol]) {
        if let course = self.currentCourse {
            submodules.forEach { $0.update(with: course, isOnline: self.isOnline) }
        }
    }

    enum Error: Swift.Error {
        case cachedFetchFailed
    }
}

extension CourseInfoInteractor: CourseInfoTabSyllabusOutputProtocol {
    func presentLesson(
        in unit: Unit,
        navigationDelegate: SectionNavigationDelegate,
        navigationRules: LessonNavigationRules
    ) {
        guard let lesson = unit.lesson else {
            return
        }

        self.presenter.presentLesson(
            response: .init(
                lesson: lesson,
                unitID: unit.id,
                navigationRules: navigationRules,
                navigationDelegate: navigationDelegate
            )
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
        return self.notificationSuggestionManager.canShowAlert(context: .courseSubscription)
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
