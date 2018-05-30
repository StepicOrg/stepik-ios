//
//  DeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class DeepLinkRouter {

    private class var window: UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    private class var currentNavigation: UINavigationController? {
        guard let tabController = currentTabBarController else {
            return nil
        }
        let cnt = tabController.viewControllers?.count ?? 0
        let index = tabController.selectedIndex
        if index < cnt {
            return tabController.viewControllers?[tabController.selectedIndex] as? UINavigationController
        } else {
            return tabController.viewControllers?[0] as? UINavigationController
        }
    }

    private class var currentTabBarController: UITabBarController? {
        return window?.rootViewController as? UITabBarController
    }

    static func routeToCatalog() {
        guard let tabController = currentTabBarController else {
            return
        }
        delay(0) {
            tabController.selectedIndex = 1
        }
    }

    static func routeToNotifications() {
        guard let tabController = currentTabBarController else {
            return
        }
        delay(0) {
            tabController.selectedIndex = 4
        }
    }

    static func routeFromDeepLink(url: URL, showAlertForUnsupported: Bool) {
        DeepLinkRouter.routeFromDeepLink(url, completion: {
            controllers in
            if controllers.count > 0 {
                if let topController = currentNavigation?.topViewController {
                    delay(0.5, closure: {
                        for (index, vc) in controllers.enumerated() {
                            if index == controllers.count - 1 {
                                topController.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                topController.navigationController?.pushViewController(vc, animated: false)
                            }
                        }
                    })
                }
            } else {
                guard showAlertForUnsupported else {
                    if let topController = currentNavigation?.topViewController {
                        WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: topController, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.close)
                    }
                    return
                }
                let alert = UIAlertController(title: NSLocalizedString("CouldNotOpenLink", comment: ""), message: NSLocalizedString("OpenInBrowserQuestion", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
                    _ in
                    UIApplication.shared.openURL(url)
                }))

                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

                UIThread.performUI {
                    window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        })
    }

    static func routeFromDeepLink(_ link: URL, completion: @escaping ([UIViewController]) -> Void) {

        func getID(_ stringId: String, reversed: Bool) -> Int? {
            var slugString = ""
            let string = reversed ? String(stringId.reversed()) : stringId
            for character in string.characters {
                if Int("\(character)") != nil {
                    if reversed {
                        slugString = "\(character)" + slugString
                    } else {
                        slugString = slugString + "\(character)"
                    }
                } else {
                    break
                }
            }
            let slugId = Int(slugString)

            return slugId
        }

        let components = link.pathComponents

        if components.count == 2 && components[1].lowercased() == "catalog" {
            routeToCatalog()
            return
        }

        if components.count == 2 && components[1].lowercased() == "notifications" {
            routeToNotifications()
            return
        }

        if components.count == 3 && components[1].lowercased() == "users" {
            guard let userId = getID(components[2], reversed: false) else {
                completion([])
                return
            }

            routeToProfileWithId(userId, completion: completion)
            return
        }

        if components.count >= 3 && components[1].lowercased() == "course" {
            guard let courseId = getID(components[2], reversed: true) else {
                completion([])
                return
            }

            if components.count == 3 {
                AnalyticsReporter.reportEvent(AnalyticsEvents.DeepLink.course, parameters: ["id": courseId as NSObject])
                routeToCourseWithId(courseId, completion: completion)
                return
            }

            if components.count == 4 && components[3].lowercased().contains("syllabus") {

                if let urlComponents = URLComponents(url: link, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems {
                    if let module = queryItems.filter({ item in item.name == "module" }).first?.value! {
                        if let moduleInt = Int(module) {
                            AnalyticsReporter.reportEvent(AnalyticsEvents.DeepLink.section, parameters: ["course": courseId as NSObject, "module": module as NSObject])
                            routeToSyllabusWithId(courseId, moduleId: moduleInt, completion: completion)
                            return
                        }
                    }
                }

                AnalyticsReporter.reportEvent(AnalyticsEvents.DeepLink.syllabus, parameters: ["id": courseId as NSObject])
                routeToSyllabusWithId(courseId, completion: completion)
                return
            }

            completion([])
            return
        }

        if components.count >= 5 && components[1].lowercased() == "lesson" {
            guard let lessonId = getID(components[2], reversed: true) else {
                completion([])
                return
            }

            guard components[3].lowercased() == "step" else {
                completion([])
                return
            }

            guard let stepId = getID(components[4], reversed: false) else {
                completion([])
                return
            }

            if link.query?.contains("discussion") ?? false {
                if let urlComponents = URLComponents(url: link, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems {
                    if let discussion = queryItems.filter({ item in item.name == "discussion" }).first?.value! {
                        if let discussionInt = Int(discussion) {
                            AnalyticsReporter.reportEvent(AnalyticsEvents.DeepLink.discussion, parameters: ["lesson": lessonId, "step": stepId, "discussion": discussionInt])
                            routeToDiscussionWithId(lessonId, stepId: stepId, discussionId: discussionInt, completion: completion)
                            return
                        }
                    }
                }
            }

            AnalyticsReporter.reportEvent(AnalyticsEvents.DeepLink.step, parameters: ["lesson": lessonId as NSObject, "step": stepId as NSObject])
            routeToStepWithId(stepId, lessonId: lessonId, completion: completion)
            return
        }

        completion([])
        return
    }

    static func routeToProfileWithId(_ userId: Int, completion: @escaping ([UIViewController]) -> Void) {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "ProfileViewController", storyboardName: "Profile") as? ProfileViewController else {
            completion([])
            return
        }

        vc.otherUserId = userId
        completion([vc])
    }

    fileprivate static func routeToCourseWithId(_ courseId: Int, completion: @escaping ([UIViewController]) -> Void) {
        if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
            do {
                let courses = Course.getCourses([courseId])
                if courses.count == 0 {
                    performRequest({
                        _ = ApiDataDownloader.courses.retrieve(ids: [courseId], existing: Course.getAllCourses(), refreshMode: .update, success: {
                            loadedCourses in
                            if loadedCourses.count == 1 {
                                UIThread.performUI {
                                    vc.course = loadedCourses[0]
                                    completion([vc])
                                }
                            } else {
                                print("error while downloading course with id \(courseId) - no courses or more than 1 returned")
                                completion([])
                                return
                            }
                            }, error: {
                                _ in
                                print("error while downloading course with id \(courseId)")
                                completion([])
                                return
                        })
                    })
                    return
                }
                if courses.count >= 1 {
                    vc.course = courses[0]
                    completion([vc])
                    return
                }
                completion([])
                return
            } catch {
                print("something bad happened")
                completion([])
                return
            }
        }

        completion([])
    }

    fileprivate static func routeToSyllabusWithId(_ courseId: Int, moduleId: Int? = nil, completion: @escaping ([UIViewController]) -> Void) {
        do {
            let courses = Course.getCourses([courseId])
            if courses.count == 0 {
                performRequest({
                    _ = ApiDataDownloader.courses.retrieve(ids: [courseId], existing: Course.getAllCourses(), refreshMode: .update, success: {
                        loadedCourses in
                        if loadedCourses.count == 1 {
                            UIThread.performUI {
                                let course = loadedCourses[0]
                                if course.enrolled {
                                    if let vc = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as?  SectionsViewController {
                                        vc.course = course
                                        vc.moduleId = moduleId
                                        completion([vc])
                                    }
                                } else {
                                    if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
                                        vc.course = course
                                        vc.displayingInfoType = DisplayingInfoType.syllabus
                                        completion([vc])
                                    }
                                }
                            }
                        } else {
                            print("error while downloading course with id \(courseId) - no courses or more than 1 returned")
                            completion([])
                            return
                        }
                        }, error: {
                            _ in
                            print("error while downloading course with id \(courseId)")
                            completion([])
                            return
                    })
                })
                return
            }
            if courses.count >= 1 {
                let course = courses[0]
                if course.enrolled {
                    if let vc = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as?  SectionsViewController {
                        vc.course = course
                        vc.moduleId = moduleId
                        completion([vc])
                    }
                } else {
                    if let vc = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as?  CoursePreviewViewController {
                        vc.course = course
                        vc.displayingInfoType = DisplayingInfoType.syllabus
                        completion([vc])
                    }
                }
                return
            }
            completion([])
            return
        } catch {
            print("something bad happened")
            completion([])
            return
        }
    }

    static func routeToStepWithId(_ stepId: Int, lessonId: Int, completion: @escaping ([UIViewController]) -> Void) {
        let router = StepsControllerDeepLinkRouter()
        router.getStepsViewControllerFor(step: stepId, inLesson: lessonId, success: {
                vc in
                completion([vc])
            }, error: {
                errorMsg in
                print(errorMsg)
                completion([])
            }
        )

    }

    static func routeToDiscussionWithId(_ lessonId: Int, stepId: Int, discussionId: Int, completion: @escaping ([UIViewController]) -> Void) {
        DeepLinkRouter.routeToStepWithId(stepId, lessonId: lessonId) { viewControllers in
            guard let lessonVC = viewControllers.first as? LessonViewController else {
                completion([])
                return
            }

            guard let stepInLessonId = lessonVC.initObjects?.lesson.stepsArray[stepId - 1] else {
                completion([])
                return
            }

            performRequest({
                ApiDataDownloader.steps.retrieve(ids: [stepInLessonId], existing: [], refreshMode: .update, success: { steps in
                    print(stepInLessonId)
                    guard let step = steps.first else {
                        completion([])
                        return
                    }

                    if let discussionProxyId = step.discussionProxyId {
                        let vc = DiscussionsViewController(nibName: "DiscussionsViewController", bundle: nil)
                        vc.discussionProxyId = discussionProxyId
                        vc.target = step.id
                        vc.step = step
                        completion([lessonVC, vc])
                    } else {
                        completion([])
                    }
                }, error: { _ in
                    completion([])
                })
            })
        }
    }
}
