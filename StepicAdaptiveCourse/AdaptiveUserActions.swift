//
//  AdaptiveUserActions.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 01.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

class AdaptiveUserActions {
    private var defaultsStorageManager: DefaultsStorageManager
    private var authAPI: AuthAPI
    private var stepicsAPI: StepicsAPI
    private var profilesAPI: ProfilesAPI
    private var enrollmentsAPI: EnrollmentsAPI
    private var coursesAPI: CoursesAPI
    private var adaptiveCoursesInfoAPI: AdaptiveCoursesInfoAPI
    private let userRegistrationService: UserRegistrationService

    init(coursesAPI: CoursesAPI, authAPI: AuthAPI, stepicsAPI: StepicsAPI, profilesAPI: ProfilesAPI, enrollmentsAPI: EnrollmentsAPI, adaptiveCoursesInfoAPI: AdaptiveCoursesInfoAPI, defaultsStorageManager: DefaultsStorageManager, userRegistrationService: UserRegistrationService? = nil) {
        self.enrollmentsAPI = enrollmentsAPI
        self.profilesAPI = profilesAPI
        self.stepicsAPI = stepicsAPI
        self.authAPI = authAPI
        self.coursesAPI = coursesAPI
        self.adaptiveCoursesInfoAPI = adaptiveCoursesInfoAPI
        self.defaultsStorageManager = defaultsStorageManager
        self.userRegistrationService = userRegistrationService == nil
            ? FakeUserRegistrationService(authAPI: authAPI, stepicsAPI: stepicsAPI, profilesAPI: profilesAPI, defaultsStorageManager: defaultsStorageManager, randomCredentialsGenerator: RandomCredentialsGeneratorImplementation())
            : userRegistrationService
    }

    func registerNewUser() -> Promise<Void> {
        return Promise { seal in
            self.userRegistrationService.registerNewUser().done { _ in
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func loadCourseAndJoin(courseId: Int) -> Promise<Course> {
        var loadedCourse: Course!
        return Promise { seal in
            Course.fetchAsync([courseId]).then { courses -> Promise<[Course]> in
                if let course = courses.first {
                    return .value([course])
                } else {
                    return self.coursesAPI.retrieve(ids: [courseId], existing: [])
                }
            }.then { courses -> Promise<Void> in
                if let course = courses.first {
                    loadedCourse = course
                    return self.joinCourse(course)
                } else {
                    return Promise(error: AdaptiveCardsStepsError.noCourse)
                }
            }.done {
                seal.fulfill(loadedCourse)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    internal func registerAdaptiveUser() -> Promise<(email: String, password: String)> {
        return userRegistrationService.registerUser()
    }

    internal func logInUser(email: String, password: String) -> Promise<User> {
        return userRegistrationService.logInUser(email: email, password: password)
    }

    internal func unregisterFromEmail(user: User) -> Promise<Void> {
        return Promise { seal in
            self.userRegistrationService.unregisterFromEmail(user: user).done { _ in
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    internal func joinCourse(_ course: Course) -> Promise<Void> {
        if course.enrolled {
            print("adaptive cards steps: already joined course")
            return .value(())
        }

        return Promise { seal in
            self.enrollmentsAPI.joinCourse(course).done {
                seal.fulfill(())
            }.catch { _ in
                seal.reject(AdaptiveCardsStepsError.joinCourseFailed)
            }
        }
    }

    internal func loadCourses(ids: [Int]) -> Promise<[Course]> {
        return Promise { seal in
            Course.fetchAsync(ids).then { courses -> Promise<[Course]> in
                if courses.count == ids.count {
                    return .value(courses)
                } else {
                    return self.coursesAPI.retrieve(ids: ids, existing: [])
                }
            }.done { courses in
                seal.fulfill(courses)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    internal func loadAdaptiveCoursesInfo(locale: String) -> Promise<[AdaptiveCourseInfo]> {
        return Promise { seal in
            adaptiveCoursesInfoAPI.retrieve(locale: locale).done { info in
                seal.fulfill(info)
            }.catch { _ in
                seal.reject(AdaptiveCardsStepsError.noCoursesInfo)
            }
        }
    }
}
