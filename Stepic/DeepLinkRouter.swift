//
//  DeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

final class DeepLinkRouter {
    static var window: UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    static var currentNavigation: UINavigationController? {
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

    static var currentTabBarController: UITabBarController? {
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

    @objc
    static func close() {
        navigationToClose?.dismiss(animated: true, completion: {
            DeepLinkRouter.navigationToClose = nil
        })
    }

    private static var navigationToClose: UIViewController?

    private static func open(modules: [UIViewController], from source: UIViewController?, isModal: Bool) {
        guard let source = source else {
            return
        }
        if isModal {
            let navigation = StyledNavigationController()
            navigation.setViewControllers(modules, animated: false)
            let closeItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(DeepLinkRouter.close))
            navigationToClose = navigation
            modules.last?.navigationItem.leftBarButtonItem = closeItem
            source.present(navigation, animated: true, completion: nil)
        } else {
            for (index, vc) in modules.enumerated() {
                source.navigationController?.pushViewController(vc, animated: index == modules.count - 1)
            }
        }
    }

    static func routeFromDeepLink(url: URL, presentFrom presentationSource: UIViewController? = nil, isModal: Bool = false, withDelay: Bool = true) {
        DeepLinkRouter.routeFromDeepLink(url, completion: { controllers in
            let navigation: UINavigationController? = presentationSource?.navigationController ?? currentNavigation
            if controllers.count > 0 {
                let openBlock = {
                    DeepLinkRouter.open(
                        modules: controllers,
                        from: presentationSource ?? navigation?.topViewController,
                        isModal: isModal
                    )
                }
                if withDelay {
                    delay(0.5, closure: {
                        openBlock()
                    })
                } else {
                    openBlock()
                }
            } else {
                let navigation: UINavigationController? = presentationSource?.navigationController ?? currentNavigation
                guard let source = presentationSource ?? navigation?.topViewController else {
                    return
                }

                guard let url = url.appendingQueryParameters(["from_mobile_app": "true"]) else {
                    return
                }

                WebControllerManager.sharedManager.presentWebControllerWithURL(
                    url,
                    inController: source,
                    withKey: "external link",
                    allowsSafari: true,
                    backButtonStyle: .close
                )
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
                            routeToDiscussionWithId(lessonId, stepId: stepId, unitID: nil, discussionId: discussionInt, completion: completion)
                            return
                        }
                    }
                }
            }

            AnalyticsReporter.reportEvent(AnalyticsEvents.DeepLink.step, parameters: ["lesson": lessonId as NSObject, "step": stepId as NSObject])
            routeToStepWithId(stepId, lessonId: lessonId, unitID: nil, completion: completion)
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

    static func routeToCourseWithId(_ courseId: Int, completion: @escaping ([UIViewController]) -> Void) {
        completion([CourseInfoAssembly(courseID: courseId).makeModule()])
    }

    static func routeToSyllabusWithId(_ courseId: Int, moduleId: Int? = nil, completion: @escaping ([UIViewController]) -> Void) {
        completion([CourseInfoAssembly(courseID: courseId, initialTab: .syllabus).makeModule()])
    }

    static func routeToStepWithId(_ stepId: Int, lessonId: Int, unitID: Int?, completion: @escaping ([UIViewController]) -> Void) {
        let router = StepsControllerDeepLinkRouter()
        router.getStepsViewControllerFor(
            step: stepId,
            inLesson: lessonId,
            withUnit: unitID,
            success: { vcs in
                completion(vcs)
            },
            error: { errorMsg in
                print(errorMsg)
                completion([])
            }
        )
    }

    static func routeToDiscussionWithId(_ lessonId: Int, stepId: Int, unitID: Int?, discussionId: Int, completion: @escaping ([UIViewController]) -> Void) {
        DeepLinkRouter.routeToStepWithId(stepId, lessonId: lessonId, unitID: unitID) { viewControllers in
            if RemoteConfig.shared.newLessonAvailable {
                guard let lessonViewController = viewControllers.last as? NewLessonViewController else {
                    completion([])
                    return
                }

                guard let stepInLessonId = Lesson.fetch([lessonId]).first?.stepsArray[safe: stepId - 1] else {
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
                            completion(viewControllers + [vc])
                        } else {
                            completion([])
                        }
                    }, error: { _ in
                        completion([])
                    })
                })
            } else {
                guard let lessonVC = viewControllers.last as? LessonViewController else {
                    completion([])
                    return
                }

                // Lesson controller can be instantiated with Lesson object (.lesson context) or with step ID (.unit context)
                let stepIDLessonContext = lessonVC.initObjects?.lesson.stepsArray[stepId - 1]
                let stepIDUnitContext = lessonVC.initIds?.stepId

                guard let stepInLessonId = stepIDLessonContext ?? stepIDUnitContext else {
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
                            completion(viewControllers + [vc])
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
}
