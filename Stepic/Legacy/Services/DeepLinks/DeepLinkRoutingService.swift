//
//  DeepLinkRoutingService.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import SVProgressHUD

final class DeepLinkRoutingService {
    private var courseViewSource: AnalyticsEvent.CourseViewSource?

    private var window: UIWindow? {
        (UIApplication.shared.delegate as? AppDelegate)?.window
    }

    private var currentNavigation: UINavigationController? {
        guard let tabController = self.currentTabBarController else {
            return nil
        }

        let count = tabController.viewControllers?.count ?? 0
        let index = tabController.selectedIndex

        if index < count {
            return tabController.viewControllers?[tabController.selectedIndex] as? UINavigationController
        } else {
            return tabController.viewControllers?[0] as? UINavigationController
        }
    }

    private var currentTabBarController: UITabBarController? {
        self.window?.rootViewController as? UITabBarController
    }

    init(courseViewSource: AnalyticsEvent.CourseViewSource? = nil) {
        self.courseViewSource = courseViewSource
    }

    func route(path: String, from source: UIViewController? = nil) {
        self.route(DeepLinkRoute(path: path), fallbackPath: path, from: source)
    }

    @discardableResult
    func route(
        _ route: DeepLinkRoute?,
        fallbackPath: String = "",
        from source: UIViewController? = nil
    ) -> Promise<Void> {
        Promise { seal in
            let fallbackURLPath = fallbackPath.isEmpty ? (route?.path ?? "") : fallbackPath
            self.getModuleStack(route: route, urlPath: fallbackURLPath).done { moduleStack in
                let router = self.makeRouter(
                    route: route,
                    from: source,
                    moduleStack: moduleStack,
                    fallbackPath: fallbackURLPath
                )
                router.route()

                seal.fulfill(())
            }.catch { error in
                print(
                    """
                    DeepLinkRoutingService :: failed route = \(String(describing: route)), \
                    fallbackPath = \(fallbackURLPath), error = \(error)
                    """
                )

                if let routerError = error as? Error {
                    switch routerError {
                    case .failedRouteToStory:
                        SVProgressHUD.showError(withStatus: routerError.errorDescription)
                    }
                }

                seal.reject(error)
            }
        }
    }

    private func makeRouter(
        route: DeepLinkRoute?,
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
        case .catalog(let courseListIDOrNil):
            return courseListIDOrNil == nil
                ? TabBarRouter(tab: .catalog())
                : ModalOrPushStackRouter(
                    source: source,
                    destinationStack: moduleStack,
                    embedInNavigation: true,
                    fallbackPath: fallbackPath
                )
        case .notifications(let section):
            return TabBarRouter(notificationsSection: section)
        case .course,
             .coursePromo,
             .coursePay,
             .courseInfo,
             .discussions,
             .solutions,
             .lesson,
             .profile,
             .syllabus,
             .certificates:
            return ModalOrPushStackRouter(
                source: source,
                destinationStack: moduleStack,
                embedInNavigation: true,
                fallbackPath: fallbackPath
            )
        case .story:
            if let sourceController = (source ?? self.currentNavigation?.topViewController),
               let destinationController = moduleStack.first {
                return ModalRouter(
                    source: sourceController,
                    destination: destinationController,
                    embedInNavigation: false
                )
            } else {
                return ModalOrPushStackRouter(
                    source: source,
                    destinationStack: moduleStack,
                    embedInNavigation: false,
                    fallbackPath: fallbackPath
                )
            }
        }
    }

    private func getModuleStack(route: DeepLinkRoute?, urlPath: String) -> Promise<[UIViewController]> {
        Promise { seal in
            guard let route = route else {
                seal.fulfill([])
                return
            }

            let courseViewSource = self.courseViewSource ?? .deepLink(url: urlPath)

            switch route {
            case .catalog(let courseListIDOrNil):
                if let courseListID = courseListIDOrNil {
                    DeepLinkRouter.routeToCatalogWithID(courseListID) { moduleStack in
                        seal.fulfill(moduleStack)
                    }
                } else {
                    seal.fulfill([])
                }
            case .notifications, .home:
                seal.fulfill([])
            case .profile(let userID):
                seal.fulfill([NewProfileAssembly(otherUserID: userID).makeModule()])
            case .course(let courseID),
                 .coursePromo(let courseID),
                 .courseInfo(let courseID):
                let assembly = CourseInfoAssembly(
                    courseID: courseID,
                    initialTab: .info,
                    courseViewSource: courseViewSource
                )
                seal.fulfill([assembly.makeModule()])
            case .coursePay(let courseID, let promoCodeName):
                let assembly = CourseInfoAssembly(
                    courseID: courseID,
                    initialTab: .info,
                    promoCodeName: promoCodeName,
                    courseViewSource: courseViewSource
                )
                seal.fulfill([assembly.makeModule()])
            case .syllabus(let courseID):
                let assembly = CourseInfoAssembly(
                    courseID: courseID,
                    initialTab: .syllabus,
                    courseViewSource: courseViewSource
                )
                seal.fulfill([assembly.makeModule()])
            case .lesson(let lessonID, let stepID, let unitID):
                DeepLinkRouter.routeToStepWithId(
                    stepID,
                    lessonID: lessonID,
                    unitID: unitID,
                    urlPath: urlPath,
                    completion: { moduleStack in
                        seal.fulfill(moduleStack)
                    }
                )
            case .discussions(let lessonID, let stepID, let discussionID, let unitID):
                DeepLinkRouter.routeToDiscussionWithID(
                    discussionID: discussionID,
                    replyID: nil,
                    thread: DiscussionThread.ThreadType.default.rawValue,
                    lessonID: lessonID,
                    stepID: stepID,
                    unitID: unitID,
                    urlPath: urlPath,
                    completion: { moduleStack in
                        seal.fulfill(moduleStack)
                    }
                )
            case .solutions(let lessonID, let stepID, let discussionID, let unitID):
                DeepLinkRouter.routeToDiscussionWithID(
                    discussionID: discussionID,
                    replyID: nil,
                    thread: DiscussionThread.ThreadType.solutions.rawValue,
                    lessonID: lessonID,
                    stepID: stepID,
                    unitID: unitID,
                    urlPath: urlPath,
                    completion: { moduleStack in
                        seal.fulfill(moduleStack)
                    }
                )
            case .certificates(let userID):
                seal.fulfill([CertificatesLegacyAssembly(userID: userID).makeModule()])
            case .story(let id):
                SVProgressHUD.show()
                DeepLinkRouter.routeToStoryWithID(id, urlPath: urlPath) { moduleStack in
                    if moduleStack.isEmpty {
                        seal.reject(Error.failedRouteToStory)
                    } else {
                        SVProgressHUD.showSuccess(withStatus: nil)
                        seal.fulfill(moduleStack)
                    }
                }
            }
        }
    }

    enum Error: Swift.Error, LocalizedError {
        case failedRouteToStory

        var errorDescription: String? {
            switch self {
            case .failedRouteToStory:
                return NSLocalizedString("DeepLinkRoutingServiceErrorStatusRouteStory", comment: "")
            }
        }
    }
}
