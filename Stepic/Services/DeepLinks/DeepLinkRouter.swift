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

    static func routeFromDeepLink(
        url: URL,
        presentFrom presentationSource: UIViewController? = nil,
        isModal: Bool = false,
        withDelay: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        DeepLinkRouter.routeFromDeepLink(url, completion: { controllers in
            let navigationController = presentationSource?.navigationController ?? self.currentNavigation

            if controllers.count > 0 {
                let openBlock = {
                    completion?()
                    DeepLinkRouter.open(
                        modules: controllers,
                        from: presentationSource ?? navigationController?.topViewController,
                        isModal: isModal
                    )
                }
                if withDelay {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        openBlock()
                    }
                } else {
                    openBlock()
                }
            } else {
                completion?()

                guard let sourceViewController = presentationSource ?? navigationController?.topViewController else {
                    return
                }

                guard let urlWithAppendedQueryParams = url.appendingQueryParameters(["from_mobile_app": "true"]) else {
                    return
                }

                WebControllerManager.sharedManager.presentWebControllerWithURL(
                    urlWithAppendedQueryParams,
                    inController: sourceViewController,
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

        if components.count == 4
           && components[1].lowercased() == "users"
           && components[3].lowercased() == "certificates" {
            guard let userID = getID(components[2], reversed: false) else {
                completion([])
                return
            }

            self.routeToCertificates(userID: userID, completion: completion)
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
                if let urlComponents = URLComponents(url: link, resolvingAgainstBaseURL: false),
                   let queryItems = urlComponents.queryItems {
                    if let discussionIDString = queryItems.first(where: { $0.name == "discussion" })?.value {
                        if let discussionID = Int(discussionIDString) {
                            let replyID = queryItems
                                .first(where: { $0.name == "amp;reply" })?
                                .value
                                .flatMap(Int.init)

                            AnalyticsReporter.reportEvent(
                                AnalyticsEvents.DeepLink.discussion,
                                parameters: [
                                    "lesson": lessonId,
                                    "step": stepId,
                                    "discussion": discussionID
                                ]
                            )

                            self.routeToDiscussionWithID(
                                discussionID: discussionID,
                                replyID: replyID,
                                lessonID: lessonId,
                                stepID: stepId,
                                unitID: nil,
                                completion: completion
                            )
                            return
                        }
                    }
                }
            }

            AnalyticsReporter.reportEvent(
                AnalyticsEvents.DeepLink.step,
                parameters: [
                    "lesson": lessonId,
                    "step": stepId
                ]
            )

            self.routeToStepWithId(stepId, lessonId: lessonId, unitID: nil, completion: completion)
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

    static func routeToCertificates(userID: User.IdType, completion: @escaping ([UIViewController]) -> Void) {
        completion([CertificatesLegacyAssembly(userID: userID).makeModule()])
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

    static func routeToDiscussionWithID(
        discussionID: Comment.IdType,
        replyID: Comment.IdType?,
        lessonID: Int,
        stepID: Int,
        unitID: Int?,
        completion: @escaping ([UIViewController]) -> Void
    ) {
        DeepLinkRouter.routeToStepWithId(stepID, lessonId: lessonID, unitID: unitID) { viewControllers in
            guard let _ = viewControllers.last as? NewLessonViewController else {
                completion([])
                return
            }

            guard let stepInLessonID = Lesson.fetch([lessonID]).first?.stepsArray[safe: stepID - 1] else {
                completion([])
                return
            }

            performRequest({
                ApiDataDownloader.steps.retrieve(
                    ids: [stepInLessonID],
                    existing: [],
                    refreshMode: .update,
                    success: { steps in
                        guard let step = steps.first else {
                            completion([])
                            return
                        }

                        if let discussionProxyID = step.discussionProxyID {
                            let assembly = DiscussionsAssembly(
                                discussionProxyID: discussionProxyID,
                                stepID: step.id,
                                presentationContext: .scrollTo(discussionID: discussionID, replyID: replyID)
                            )
                            completion(viewControllers + [assembly.makeModule()])
                        } else {
                            completion([])
                        }
                    },
                    error: { _ in
                        completion([])
                    }
                )
            })
        }
    }
}
