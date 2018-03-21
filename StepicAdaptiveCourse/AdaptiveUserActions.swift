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

    init(coursesAPI: CoursesAPI, authAPI: AuthAPI, stepicsAPI: StepicsAPI, profilesAPI: ProfilesAPI, enrollmentsAPI: EnrollmentsAPI, adaptiveCoursesInfoAPI: AdaptiveCoursesInfoAPI, defaultsStorageManager: DefaultsStorageManager) {
        self.enrollmentsAPI = enrollmentsAPI
        self.profilesAPI = profilesAPI
        self.stepicsAPI = stepicsAPI
        self.authAPI = authAPI
        self.coursesAPI = coursesAPI
        self.adaptiveCoursesInfoAPI = adaptiveCoursesInfoAPI
        self.defaultsStorageManager = defaultsStorageManager
    }

    func registerNewUser() -> Promise<Void> {
        return Promise { fulfill, reject in
            checkToken().then {
                self.registerAdaptiveUser()
            }.then { email, password -> Promise<User> in
                self.logInUser(email: email, password: password)
            }.then { user -> Promise<Void> in
                self.unregisterFromEmail(user: user)
            }.then { _ -> Void in
                fulfill(())
            }.catch { error in
                reject(error)
            }
        }
    }

    func loadCourseAndJoin(courseId: Int) -> Promise<Course> {
        var loadedCourse: Course!
        return Promise { fulfill, reject in
            Course.fetchAsync([courseId]).then { courses -> Promise<[Course]> in
                if let course = courses.first {
                    return Promise(value: [course])
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
            }.then { _ in
                fulfill(loadedCourse)
            }.catch { error in
                reject(error)
            }
        }
    }

    internal func registerAdaptiveUser() -> Promise<(email: String, password: String)> {
        if let savedEmail = defaultsStorageManager.accountEmail,
           let savedPassword = defaultsStorageManager.accountPassword {
            return Promise(value: (email: savedEmail, password: savedPassword))
        }

        let firstname = StringHelper.generateRandomString(of: 6)
        let lastname = StringHelper.generateRandomString(of: 6)
        let email = "adaptive_\(StepicApplicationsInfo.adaptiveSupportedCourses.first ?? 0)_ios_\(Int(Date().timeIntervalSince1970))\(StringHelper.generateRandomString(of: 5))@stepik.org"
        let password = StringHelper.generateRandomString(of: 16)

        return Promise { fulfill, reject in
            self.authAPI.signUpWithAccount(firstname: firstname, lastname: lastname, email: email, password: password).then { _ -> Void in
                fulfill((email: email, password: password))
            }.catch { error in
                print("adaptive cards steps: error while user register, error = \(error)")
                reject(AdaptiveCardsStepsError.userNotRegistered)
            }
        }
    }

    internal func logInUser(email: String, password: String) -> Promise<User> {
        defaultsStorageManager.accountEmail = email
        defaultsStorageManager.accountPassword = password

        return Promise { fulfill, reject in
            self.authAPI.signInWithAccount(email: email, password: password).then { token, authorizationType -> Promise<User> in
                AuthInfo.shared.token = token
                AuthInfo.shared.authorizationType = authorizationType

                return self.stepicsAPI.retrieveCurrentUser()
            }.then { user -> Void in
                AuthInfo.shared.user = user
                User.removeAllExcept(user)

                fulfill(user)
            }.catch { error in
                print("adaptive cards steps: error while user login, error = \(error)")
                reject(AdaptiveCardsStepsError.userNotLoggedIn)
            }
        }
    }

    internal func unregisterFromEmail(user: User) -> Promise<Void> {
        return Promise { fulfill, reject in
            self.profilesAPI.retrieve(ids: [user.profile], existing: []).then { profiles -> Promise<Profile> in
                if let profile = profiles.first {
                    profile.subscribedForMail = false
                    return self.profilesAPI.update(profile)
                } else {
                    print("adaptive cards stepts: profile not found")
                    return Promise(error: AdaptiveCardsStepsError.noProfile)
                }
            }.then { _ -> Void in
                fulfill(())
            }.catch { error in
                print("adaptive cards steps: error while unregister user from emails, error = \(error)")
                reject(AdaptiveCardsStepsError.userNotUnregisteredFromEmails)
            }
        }
    }

    internal func joinCourse(_ course: Course) -> Promise<Void> {
        if course.enrolled {
            print("adaptive cards steps: already joined course")
            return Promise(value: ())
        }

        return Promise { fulfill, reject in
            self.enrollmentsAPI.joinCourse(course).then {
                fulfill(())
            }.catch { _ in
                reject(AdaptiveCardsStepsError.joinCourseFailed)
            }
        }
    }

    internal func loadCourses(ids: [Int]) -> Promise<[Course]> {
        return Promise { fulfill, reject in
            Course.fetchAsync(ids).then { courses -> Promise<[Course]> in
                if courses.count == ids.count {
                    return Promise(value: courses)
                } else {
                    return self.coursesAPI.retrieve(ids: ids, existing: [])
                }
            }.then { courses -> Void in
                fulfill(courses)
            }.catch { error in
                reject(error)
            }
        }
    }

    internal func loadAdaptiveCoursesInfo(locale: String) -> Promise<[AdaptiveCourseInfo]> {
        return Promise { fulfill, reject in
            adaptiveCoursesInfoAPI.retrieve(locale: locale).then { info in
                fulfill(info)
            }.catch { _ in
                reject(AdaptiveCardsStepsError.noCoursesInfo)
            }
        }
    }
}
