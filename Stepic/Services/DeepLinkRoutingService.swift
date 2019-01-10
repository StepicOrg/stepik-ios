//
//  DeepLinkRoutingService.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Regex
import PromiseKit

class DeepLinkRoutingService {

    private var window: UIWindow? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    private var currentNavigation: UINavigationController? {
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

    private var currentTabBarController: UITabBarController? {
        return window?.rootViewController as? UITabBarController
    }

    func route(path: String, from source: UIViewController? = nil) {
        self.route(Route(path: path), fallbackPath: path, from: source)
    }

    func route(_ route: Route?, fallbackPath: String = "", from source: UIViewController? = nil) {
        self.getModuleStack(route: route).done { moduleStack in
            let router = self.makeRouter(route: route, from: source, moduleStack: moduleStack, fallbackPath: fallbackPath)
            router.route()
        }.catch { _ in
            //TODO: Handle this
            print("network error during routing, handle this")
        }
    }

    private func makeRouter(
        route: Route?,
        from source: UIViewController?,
        moduleStack: [UIViewController],
        fallbackPath: String
    ) -> RouterProtocol {
        guard let route = route else {
            return ModalOrPushStackRouter(
                source: source,
                destinationStack: moduleStack,
                embedInNavigation: false,
                fallbackPath: fallbackPath
            )
        }

        switch route {
        case .home:
            return TabBarRouter(tab: .home)
        case .catalog:
            return TabBarRouter(tab: .catalog)
        case .notifications(let section):
            return TabBarRouter(notificationsSection: section)
        case .course, .discussions, .lesson, .profile, .syllabus:
            return ModalOrPushStackRouter(
                source: source,
                destinationStack: moduleStack,
                embedInNavigation: true,
                fallbackPath: fallbackPath
            )
        }
    }

    private func getModuleStack(route: Route?) -> Promise<[UIViewController]> {
        return Promise { seal in
            guard let route = route else {
                seal.fulfill([])
                return
            }

            switch route {
            case .catalog, .notifications, .home:
                seal.fulfill([])
            case .profile(userID: let userID):
                seal.fulfill([ProfileAssembly(userID: userID).makeModule()])
            case .course(courseID: let courseID):
                seal.fulfill([CourseInfoAssembly(courseID: courseID, initialTab: .info).makeModule()])
            case .syllabus(courseID: let courseID):
                seal.fulfill([CourseInfoAssembly(courseID: courseID, initialTab: .syllabus).makeModule()])
            case .lesson(lessonID: let lessonID, stepID: let stepID, unitID: _):
                DeepLinkRouter.routeToStepWithId(stepID, lessonId: lessonID, completion: { moduleStack in
                    seal.fulfill(moduleStack)
                })
            case .discussions(lessonID: let lessonID, stepID: let stepID, discussionID: let discussionID, unitID: _):
                DeepLinkRouter.routeToDiscussionWithId(lessonID, stepId: stepID, discussionId: discussionID, completion: { moduleStack in
                    seal.fulfill(moduleStack)
                })
            }
        }
    }
}

extension DeepLinkRoutingService {
    enum Pattern: String {
        case catalog = "https:\\/\\/stepik.org\\/catalog\\/?"
        case course = "https:\\/\\/stepik.org\\/(?:course\\/|course\\/[a-zа-я-]+|)(\\d+)\\/?"
        case profile = "https:\\/\\/stepik.org\\/users\\/(\\d+)\\/?"
        case notifications = "https:\\/\\/stepik.org\\/notifications\\/?"
        case syllabus = "https:\\/\\/stepik.org\\/(?:course\\/|course\\/[a-zа-я-]+)(\\d+)\\/syllabus\\/?[a-zа-я0-9=?&]*"
        case lesson = "https:\\/\\/stepik.org\\/(?:lesson\\/|lesson\\/[a-zа-я-]+)(\\d+)\\/step\\/(\\d+)(?:\\?unit=(\\d+))?\\/?"
        case discussions = "https:\\/\\/stepik.org\\/(?:lesson\\/|lesson\\/[a-zа-я-]+)(\\d+)\\/step\\/(\\d+)(?:\\?discussion=(\\d+))(?:\\&unit=(\\d+))?\\/?"

        var regex: Regex {
            return try! Regex(string: self.rawValue, options: [.ignoreCase])
        }
    }

    enum Route {
        case lesson(lessonID: Int, stepID: Int, unitID: Int?)
        case notifications(section: NotificationsSection)
        case discussions(lessonID: Int, stepID: Int, discussionID: Int, unitID: Int?)
        case profile(userID: Int)
        case syllabus(courseID: Int)
        case catalog
        case home
        case course(courseID: Int)

        init?(path: String) {
            if let match = Pattern.catalog.regex.firstMatch(in: path),
               match.matchedString == path {
                self = .catalog
                return
            }

            if let match = Pattern.course.regex.firstMatch(in: path),
               let courseIDString = match.captures[0],
               let courseID = Int(courseIDString),
               match.matchedString == path {
                self = .course(courseID: courseID)
                return
            }

            if let match = Pattern.profile.regex.firstMatch(in: path),
               let userIDString = match.captures[0], let userID = Int(userIDString),
               match.matchedString == path {
                self = .profile(userID: userID)
                return
            }

            if let match = Pattern.notifications.regex.firstMatch(in: path),
               match.matchedString == path {
                self = .notifications(section: .all)
                return
            }

            if let match = Pattern.syllabus.regex.firstMatch(in: path),
               let courseIDString = match.captures[0],
               let courseID = Int(courseIDString),
               match.matchedString == path {
                self = .syllabus(courseID: courseID)
                return
            }

            if let match = Pattern.lesson.regex.firstMatch(in: path),
               let lessonIDString = match.captures[0], let lessonID = Int(lessonIDString),
               let stepIDString = match.captures[1], let stepID = Int(stepIDString),
               match.matchedString == path {
                let unitID = match.captures[2].flatMap { Int($0) }
                self = .lesson(lessonID: lessonID, stepID: stepID, unitID: unitID)
                return
            }

            if let match = Pattern.discussions.regex.firstMatch(in: path),
               let lessonIDString = match.captures[0], let lessonID = Int(lessonIDString),
               let stepIDString = match.captures[1], let stepID = Int(stepIDString),
               let discussionIDString = match.captures[2], let discussionID = Int(discussionIDString),
               match.matchedString == path {
                let unitID = match.captures[3].flatMap { Int($0) }
                self = .discussions(lessonID: lessonID, stepID: stepID, discussionID: discussionID, unitID: unitID)
                return
            }
            return nil
        }
    }
}
