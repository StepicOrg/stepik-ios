//
//  DeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class DeepLinkRouter {
    static var window: UIWindow? {
        (UIApplication.shared.delegate as? AppDelegate)?.window
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
        self.window?.rootViewController as? UITabBarController
    }

    static func routeToCatalog() {
        guard let tabController = self.currentTabBarController else {
            return
        }

        DispatchQueue.main.async {
            tabController.selectedIndex = TabBarRouter.Tab.catalog(searchCourses: false).index
        }
    }

    static func routeToNotifications() {
        guard let tabController = self.currentTabBarController else {
            return
        }

        DispatchQueue.main.async {
            tabController.selectedIndex = TabBarRouter.Tab.notifications.index
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
            let navigationController = StyledNavigationController()
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.setViewControllers(modules, animated: false)

            let closeBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(DeepLinkRouter.close)
            )
            self.navigationToClose = navigationController
            modules.last?.navigationItem.leftBarButtonItem = closeBarButtonItem

            source.present(navigationController, animated: true, completion: nil)
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

                WebControllerManager.shared.presentWebControllerWithURL(
                    urlWithAppendedQueryParams,
                    inController: sourceViewController,
                    withKey: .externalLink,
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
            for character in string {
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
            guard let courseID = getID(components[2], reversed: true) else {
                completion([])
                return
            }

            if components.count == 3 {
                StepikAnalytics.shared.send(.deepLinkCourse(id: courseID))
                routeToCourseWithID(courseID, urlPath: link.absoluteString, completion: completion)
                return
            }

            if components.count == 4 && components[3].lowercased().contains("syllabus") {
                if let urlComponents = URLComponents(url: link, resolvingAgainstBaseURL: false),
                   let queryItems = urlComponents.queryItems {
                    if let module = queryItems.filter({ item in item.name == "module" }).first?.value! {
                        if let moduleInt = Int(module) {
                            StepikAnalytics.shared.send(.deepLinkSection(courseID: courseID, moduleID: moduleInt))
                            routeToSyllabusWithID(
                                courseID,
                                moduleID: moduleInt,
                                urlPath: link.absoluteString,
                                completion: completion
                            )
                            return
                        }
                    }
                }

                StepikAnalytics.shared.send(.deepLinkSyllabus(courseID: courseID))
                routeToSyllabusWithID(courseID, urlPath: link.absoluteString, completion: completion)
                return
            }

            completion([])
            return
        }

        if components.count >= 5 && components[1].lowercased() == "lesson" {
            guard let lessonID = getID(components[2], reversed: true) else {
                completion([])
                return
            }

            guard components[3].lowercased() == "step" else {
                completion([])
                return
            }

            guard let stepID = getID(components[4], reversed: false) else {
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
                            let threadValue = queryItems.first(where: { $0.name == "amp;thread" })?.value

                            StepikAnalytics.shared.send(
                                .deepLinkDiscussion(lessonID: lessonID, stepID: stepID, discussionID: discussionID)
                            )

                            self.routeToDiscussionWithID(
                                discussionID: discussionID,
                                replyID: replyID,
                                thread: threadValue,
                                lessonID: lessonID,
                                stepID: stepID,
                                unitID: nil,
                                urlPath: link.absoluteString,
                                completion: completion
                            )
                            return
                        }
                    }
                }
            }

            StepikAnalytics.shared.send(.deepLinkStep(lessonID: lessonID, stepID: stepID))

            self.routeToStepWithId(
                stepID,
                lessonID: lessonID,
                unitID: nil,
                urlPath: link.absoluteString,
                completion: completion
            )

            return
        }

        completion([])
        return
    }

    static func routeToStoryWithID(
        _ id: Story.IdType,
        urlPath: String,
        completion: @escaping ([UIViewController]) -> Void
    ) {
        struct Holder {
            static var networkService = StoryTemplatesNetworkService(storyTemplatesAPI: StoryTemplatesAPI())
        }

        Holder.networkService.fetch(id: id).then { storyOrNil -> Promise<(Story, [Story])> in
            guard let story = storyOrNil else {
                throw Error.fetchFailed
            }

            return Holder.networkService.fetch(
                language: ContentLanguageService().globalContentLanguage,
                maxVersion: StepikApplicationsInfo.Versions.stories ?? 0,
                isPublished: AuthInfo.shared.user?.profileEntity?.isStaff != true ? true : nil
            ).map { (story, $0) }
        }.done { deepLinkStory, allStories in
            let resultStories = (
                allStories.contains(where: { $0.id == deepLinkStory.id }) ? allStories : (allStories + [deepLinkStory])
            ).filter {
                $0.isSupported
            }.sorted {
                $0.position >= $1.position
            }.sorted {
                !($0.isViewed.value) || ($1.isViewed.value)
            }

            guard let deepLinkStoryIndex = resultStories.firstIndex(where: { $0.id == deepLinkStory.id }) else {
                return completion([])
            }

            let assembly = OpenedStoriesAssembly(
                stories: resultStories,
                startPosition: deepLinkStoryIndex,
                storyOpenSource: .deeplink(path: urlPath),
                moduleOutput: nil
            )

            completion([assembly.makeModule()])
        }.catch { _ in
            completion([])
        }
    }

    static func routeToCatalogWithID(_ id: CourseListModel.IdType, completion: @escaping ([UIViewController]) -> Void) {
        struct Holder {
            static var persistenceService = CourseListsPersistenceService()
            static var networkService = CourseListsNetworkService(courseListsAPI: CourseListsAPI())
        }

        let persistenceGuarantee = Holder.persistenceService.fetch(id: id)
        let networkGuarantee = Guarantee { seal in
            Holder.networkService.fetch(id: id).done { courseLists, _ in
                seal(courseLists.first)
            }.catch { _ in
                seal(nil)
            }
        }

        when(
            fulfilled: persistenceGuarantee,
            networkGuarantee
        ).then { cachedCourseList, remoteCourseList -> Promise<CourseListModel?> in
            if let remoteCourseList = remoteCourseList {
                return .value(remoteCourseList)
            } else {
                return .value(cachedCourseList)
            }
        }.done { courseListOrNil in
            guard let courseList = courseListOrNil else {
                completion([])
                return
            }

            let presentationDescription: CourseList.PresentationDescription? = {
                let title = courseList.title
                let subtitle = courseList.listDescription.isEmpty
                    ? FormatterHelper.coursesCount(courseList.coursesArray.count)
                    : courseList.listDescription
                let color = GradientCoursesPlaceholderView.Color.allCases.randomElement() ?? .blue

                if title.isEmpty && subtitle.isEmpty {
                    return nil
                }

                return CourseList.PresentationDescription(
                    headerViewDescription: .init(
                        title: title,
                        subtitle: subtitle,
                        color: color
                    )
                )
            }()

            let courseViewSource: AnalyticsEvent.CourseViewSource? = {
                let catalogURLOrNil = StepikURLFactory().makeCatalog(id: id)
                if let catalogURL = catalogURLOrNil {
                    return .deepLink(url: catalogURL.absoluteString)
                }
                return nil
            }()

            let assembly = FullscreenCourseListAssembly(
                presentationDescription: presentationDescription,
                courseListType: DeepLinkCourseListType(ids: courseList.coursesArray),
                courseViewSource: courseViewSource
            )
            completion([assembly.makeModule()])
        }.catch { _ in
            completion([])
        }
    }

    static func routeToProfileWithId(_ userId: Int, completion: @escaping ([UIViewController]) -> Void) {
        let assembly = NewProfileAssembly(otherUserID: userId)
        completion([assembly.makeModule()])
    }

    static func routeToCertificates(userID: User.IdType, completion: @escaping ([UIViewController]) -> Void) {
        completion([CertificatesLegacyAssembly(userID: userID).makeModule()])
    }

    static func routeToCourseWithID(
        _ courseID: Int,
        urlPath: String,
        completion: @escaping ([UIViewController]) -> Void
    ) {
        let assembly = CourseInfoAssembly(courseID: courseID, courseViewSource: .deepLink(url: urlPath))
        completion([assembly.makeModule()])
    }

    static func routeToSyllabusWithID(
        _ courseID: Int,
        moduleID: Int? = nil,
        urlPath: String,
        completion: @escaping ([UIViewController]) -> Void
    ) {
        let assembly = CourseInfoAssembly(
            courseID: courseID,
            initialTab: .syllabus,
            courseViewSource: .deepLink(url: urlPath)
        )
        completion([assembly.makeModule()])
    }

    static func routeToStepWithId(
        _ stepID: Int,
        lessonID: Int,
        unitID: Int?,
        urlPath: String,
        completion: @escaping ([UIViewController]) -> Void
    ) {
        let router = StepsControllerDeepLinkRouter(courseViewSource: .deepLink(url: urlPath))
        router.getStepsViewControllerFor(
            step: stepID,
            inLesson: lessonID,
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
        thread: String?,
        lessonID: Int,
        stepID: Int,
        unitID: Int?,
        urlPath: String,
        completion: @escaping ([UIViewController]) -> Void
    ) {
        Self.routeToStepWithId(stepID, lessonID: lessonID, unitID: unitID, urlPath: urlPath) { viewControllers in
            guard let _ = viewControllers.last as? LessonViewController else {
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
                            return completion([])
                        }

                        let threadTypeOrNil: DiscussionThread.ThreadType? = thread == nil
                            ? .default
                            : DiscussionThread.ThreadType(rawValue: thread ?? "")

                        guard let threadType = threadTypeOrNil else {
                            return completion([])
                        }

                        switch threadType {
                        case .default:
                            guard let discussionProxyID = step.discussionProxyID else {
                                return completion([])
                            }

                            let assembly = DiscussionsAssembly(
                                discussionThreadType: .default,
                                discussionProxyID: discussionProxyID,
                                stepID: step.id,
                                presentationContext: .scrollTo(discussionID: discussionID, replyID: replyID)
                            )
                            completion(viewControllers + [assembly.makeModule()])
                        case .solutions:
                            guard let discussionThreadsIDs = step.discussionThreadsArray else {
                                return completion([])
                            }

                            ApiDataDownloader.discussionThreads.retrieve(ids: discussionThreadsIDs).done {
                                discussionThreads, _ in
                                guard let discussionThread = discussionThreads.first(
                                    where: { $0.threadType == .solutions }
                                ) else {
                                    return completion([])
                                }

                                let assembly = DiscussionsAssembly(
                                    discussionThreadType: .solutions,
                                    discussionProxyID: discussionThread.discussionProxy,
                                    stepID: step.id,
                                    presentationContext: .scrollTo(discussionID: discussionID, replyID: replyID)
                                )
                                completion(viewControllers + [assembly.makeModule()])
                            }.catch { _ in
                                completion([])
                            }
                        }
                    },
                    error: { _ in
                        completion([])
                    }
                )
            })
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
