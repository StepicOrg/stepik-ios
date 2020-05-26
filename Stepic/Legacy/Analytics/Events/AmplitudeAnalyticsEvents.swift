import Foundation

extension AnalyticsEvent {
    // MARK: - Launch -

    static let applicationDidLaunchFirstTime = AmplitudeAnalyticsEvent(name: "Launch first time")

    static func applicationDidLaunchWithOptions(
        notificationType: String? = nil,
        secondsSinceLastSession: TimeInterval
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Session start",
            parameters: [
                "notification_type": notificationType as Any,
                "seconds_since_last_session": secondsSinceLastSession
            ]
        )
    }

    // MARK: - Onboarding -

    static let onboardingCompleted = AmplitudeAnalyticsEvent(name: "Onboarding completed")

    static func onboardingScreenOpened(index: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Onboarding screen opened",
            parameters: [
                "screen": index
            ]
        )
    }

    static func onboardingScreenClosed(index: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Onboarding closed",
            parameters: [
                "screen": index
            ]
        )
    }

    // MARK: - SignIn -

    static func signInSucceeded(source: AuthenticationSource) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Logged in",
            parameters: [
                "source": source.description
            ]
        )
    }

    enum AuthenticationSource {
        case email
        case social(SocialProviderInfo)

        fileprivate var description: String {
            switch self {
            case .email:
                return "email"
            case .social(let provider):
                return provider.amplitudeName
            }
        }
    }

    // MARK: - SignUp -

    static func signUpSucceeded(source: AuthenticationSource) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Registered",
            parameters: [
                "source": source.description
            ]
        )
    }

    // MARK: - Course -

    static func courseJoined(source: CourseSubscriptionSource, id: Int, title: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course joined",
            parameters: [
                "source": source.rawValue,
                "course": id,
                "title": title
            ]
        )
    }

    static func courseUnsubscribed(id: Int, title: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course unsubscribed",
            parameters: [
                "course": id,
                "title": title
            ]
        )
    }

    static func courseContinuePressed(source: CourseContinueSource, id: Int, title: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Continue course pressed",
            parameters: [
                "source": source.rawValue,
                "course": id,
                "title": title
            ]
        )
    }

    enum CourseContinueSource: String {
        case courseWidget = "course_widget"
        case homeWidget = "home_widget"
        case courseScreen = "course_screen"
    }

    static func courseBuyPressed(source: CourseBuySource, id: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course pressed",
            parameters: [
                "source": source.rawValue,
                "course": id
            ]
        )
    }

    enum CourseBuySource: String {
        case courseWidget = "course_widget"
        case courseScreen = "course_screen"
    }

    // MARK: - Steps -

    static func submissionMade(
        stepID: Int,
        submissionID: Int,
        blockName: String,
        isAdaptive: Bool? = nil,
        codeLanguageName: String? = nil
    ) -> AmplitudeAnalyticsEvent {
        var parameters: [String: Any] = [
            "step": stepID,
            "submission": submissionID,
            "type": blockName
        ]

        if let isAdaptive = isAdaptive {
            parameters["is_adaptive"] = isAdaptive
        }

        if let codeLanguageName = codeLanguageName {
            parameters["language"] = codeLanguageName
        }

        return AmplitudeAnalyticsEvent(name: "Submission made", parameters: parameters)
    }

    static func stepOpened(id: Int, blockName: String, position: Int? = nil) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Step opened",
            parameters: [
                "step": id,
                "type": blockName,
                "number": position as Any
            ]
        )
    }

    // MARK: - EditStep -

    static func editStepOpened(stepID: Int, blockName: String, position: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Step edit opened",
            parameters: [
                "step": stepID,
                "type": blockName,
                "number": position
            ]
        )
    }

    static func editStepCompleted(stepID: Int, blockName: String, position: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Step edit completed",
            parameters: [
                "step": stepID,
                "type": blockName,
                "number": position
            ]
        )
    }

    // MARK: - Downloads -

    static let downloadsScreenOpened = AmplitudeAnalyticsEvent(name: "Downloads screen opened")

    static func downloadStarted(content: DownloadContent) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(name: "Download started", parameters: ["content": content.rawValue])
    }

    static func downloadCancelled(content: DownloadContent) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(name: "Download cancelled", parameters: ["content": content.rawValue])
    }

    static func downloadDeleted(content: DownloadContent, source: DeleteDownloadSource) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Download deleted",
            parameters: [
                "content": content.rawValue,
                "source": source.rawValue
            ]
        )
    }

    static func deleteDownloadConfirmationInteracted(
        content: DownloadContent,
        isConfirmed: Bool
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Delete downloads confirmation interacted",
            parameters: [
                "content": content.rawValue,
                "result": isConfirmed ? "yes" : "no"
            ]
        )
    }

    enum DownloadContent: String {
        case course
        case section
        case lesson
        case step
    }

    enum DeleteDownloadSource: String {
        case syllabus
        case downloads
    }

    // MARK: - Search -

    static let courseSearchStarted = AmplitudeAnalyticsEvent(name: "Course search started")

    static func courseSearched(query: String, position: Int, suggestion: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course searched",
            parameters: [
                "query": query,
                "position": position,
                "suggestion": suggestion
            ]
        )
    }

    // MARK: - Notifications -

    static let notificationsScreenOpened = AmplitudeAnalyticsEvent(name: "Notifications screen opened")

    static func foregroundNotificationReceived(notificationType: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Foreground notification received",
            parameters: [
                "notification_type": notificationType
            ]
        )
    }

    static func inactiveNotificationReceived(notificationType: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Inactive notification received",
            parameters: [
                "notification_type": notificationType
            ]
        )
    }

    static func requestNotificationsAuthorizationDefaultAlertShown(source: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Default notification alert shown",
            parameters: [
                "source": source
            ]
        )
    }

    static func requestNotificationsAuthorizationDefaultAlertInteracted(
        source: String,
        result: String
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Default notification alert interacted",
            parameters: [
                "source": source,
                "result": result
            ]
        )
    }

    static func requestNotificationsAuthorizationCustomAlertShown(source: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Custom notification alert shown",
            parameters: [
                "source": source
            ]
        )
    }

    static func requestNotificationsAuthorizationCustomAlertInteracted(
        source: String,
        result: String
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Custom notification alert interacted",
            parameters: [
                "source": source,
                "result": result
            ]
        )
    }

    static func requestNotificationsAuthorizationPreferencesAlertShown(source: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Preferences notification alert shown",
            parameters: [
                "source": source
            ]
        )
    }

    static func requestNotificationsAuthorizationPreferencesAlertInteracted(
        source: String,
        result: String
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Preferences notification alert interacted",
            parameters: [
                "source": source,
                "result": result
            ]
        )
    }

    static func notificationsPushPermissionPreferenceChanged(isRegistered: Bool) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Preferences push permission changed",
            parameters: [
                "result": isRegistered ? "yes" : "no"
            ]
        )
    }

    // MARK: - Home -

    static let homeScreenOpened = AmplitudeAnalyticsEvent(name: "Home screen opened")

    // MARK: - Catalog -

    static let catalogScreenOpened = AmplitudeAnalyticsEvent(name: "Catalog screen opened")

    static func catalogCategoryOpened(categoryID: Int, categoryNameEn: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Category opened",
            parameters: [
                "category_id": categoryID,
                "category_name_en": categoryNameEn
            ]
        )
    }

    // MARK: - CourseList -

    static let courseListShowAllTapped = AmplitudeAnalyticsEvent(name: "Course list show all clicked")

    // MARK: - Profile -

    static func profileScreenOpened(state: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Profile screen opened",
            parameters: [
                "state": state
            ]
        )
    }

    // MARK: - Profile Edit -

    static let profileEditScreenOpened = AmplitudeAnalyticsEvent(name: "Profile edit screen opened")

    static let profileEditSaved = AmplitudeAnalyticsEvent(name: "Profile edit saved")

    // MARK: - Certificates -

    static let certificatesScreenOpened = AmplitudeAnalyticsEvent(name: "Certificates screen opened")

    // MARK: - Achievements -

    static func achievementsScreenOpened(isPersonal: Bool) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Achievements screen opened",
            parameters: [
                "is_personal": isPersonal
            ]
        )
    }

    static func achievementPopupOpened(source: String, kind: String, level: Int? = nil) -> AmplitudeAnalyticsEvent {
        achievementsPopupEvent(name: "Achievement popup opened", source: source, kind: kind, level: level)
    }

    static func achievementPopupShared(source: String, kind: String, level: Int? = nil) -> AmplitudeAnalyticsEvent {
        achievementsPopupEvent(name: "Achievement share pressed", source: source, kind: kind, level: level)
    }

    private static func achievementsPopupEvent(
        name: String,
        source: String,
        kind: String,
        level: Int? = nil
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: name,
            parameters: [
                "source": source,
                "achievement_kind": kind,
                "achievement_level": level as Any
            ]
        )
    }

    // MARK: - Settings -

    static let settingsScreenOpened = AmplitudeAnalyticsEvent(name: "Settings screen opened")

    static func settingsStepFontSizeSelected(_ fontSize: StepFontSize) -> AmplitudeAnalyticsEvent {
        let fontSizeStringValue: String = {
            switch fontSize {
            case .small:
                return "small"
            case .medium:
                return "medium"
            case .large:
                return "large"
            }
        }()

        return AmplitudeAnalyticsEvent(name: "Font size selected", parameters: ["size": fontSizeStringValue])
    }

    // MARK: - CoursePreview -

    static func coursePreviewScreenOpened(course: Course, viewSource: CourseViewSource) -> AmplitudeAnalyticsEvent {
        var params: [String: Any] = [
            "course": course.id,
            "title": course.title,
            "is_paid": course.isPaid,
            "source": viewSource.name
        ]

        if let courseViewSourceParams = viewSource.params {
            for (key, value) in courseViewSourceParams {
                params["\(viewSource.name)_\(key)"] = value
            }
        }

        return AmplitudeAnalyticsEvent(name: "Course preview screen opened", parameters: params)
    }

    enum CourseViewSource {
        case myCourses
        case downloads
        case fastContinue
        case search(query: String)
        case collection(id: Int)
        case query(courseListType: CourseListType)
        case story(id: Int)
        case deepLink(url: String)
        case notification
        case unknown

        var name: String {
            switch self {
            case .myCourses:
                return "my_courses"
            case .downloads:
                return "downloads"
            case .fastContinue:
                return "fast_continue"
            case .search:
                return "search"
            case .collection:
                return "collection"
            case .query:
                return "query"
            case .story:
                return "story"
            case .deepLink:
                return "deeplink"
            case .notification:
                return "notification"
            case .unknown:
                return "unknown"
            }
        }

        var params: [String: Any]? {
            switch self {
            case .myCourses, .downloads, .fastContinue, .notification, .unknown:
                return nil
            case .search(let query):
                return ["query": query]
            case .collection(let id):
                return ["collection": id]
            case .query(let courseListType):
                var params: [String: Any] = [
                    "type": courseListType.analyticName
                ]

                if let popularCourseListType = courseListType as? PopularCourseListType {
                    params["language"] = popularCourseListType.language.languageString
                } else if let tagCourseListType = courseListType as? TagCourseListType {
                    params["id"] = tagCourseListType.id
                    params["language"] = tagCourseListType.language.languageString
                } else if let collectionCourseListType = courseListType as? CollectionCourseListType {
                    params["ids"] = collectionCourseListType.ids
                } else if let searchResultCourseListType = courseListType as? SearchResultCourseListType {
                    params["query"] = searchResultCourseListType.query
                    params["language"] = searchResultCourseListType.language.languageString
                }

                return params
            case .story(let id):
                return ["story": id]
            case .deepLink(let url):
                return ["url": url]
            }
        }
    }

    // MARK: - Sections -

    static func sectionsScreenOpened(courseID: Int, courseTitle: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Sections screen opened",
            parameters: [
                "course": courseID,
                "title": courseTitle
            ]
        )
    }

    // MARK: - CourseReviews -

    static func courseReviewsScreenOpened(courseID: Int, courseTitle: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course reviews screen opened",
            parameters: [
                "course": courseID,
                "title": courseTitle
            ]
        )
    }

    static func writeCourseReviewPressed(courseID: Int, courseTitle: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Create course review pressed",
            parameters: [
                "course": courseID,
                "title": courseTitle
            ]
        )
    }

    static func editCourseReviewPressed(courseID: Int, courseTitle: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Edit course review pressed",
            parameters: [
                "course": courseID,
                "title": courseTitle
            ]
        )
    }

    static func courseReviewCreated(courseID: Int, rating: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course review created",
            parameters: [
                "course": courseID,
                "rating": rating
            ]
        )
    }

    static func courseReviewUpdated(courseID: Int, fromRating: Int, toRating: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course review updated",
            parameters: [
                "course": courseID,
                "from_rating": fromRating,
                "to_rating": toRating
            ]
        )
    }

    static func courseReviewDeleted(courseID: Int, rating: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course review deleted",
            parameters: [
                "course": courseID,
                "rating": rating
            ]
        )
    }

    // MARK: - Discussions -

    static func discussionsScreenOpened(source: DiscussionsSource) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Discussions screen opened",
            parameters: [
                "source": source.rawValue
            ]
        )
    }

    enum DiscussionsSource: String {
        case discussion
        case reply
        case `default`
    }

    // MARK: - Stories -

    static func storyOpened(id: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Story opened",
            parameters: [
                "id": id
            ]
        )
    }

    static func storyPartOpened(id: Int, position: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Story part opened",
            parameters: [
                "id": id,
                "position": position
            ]
        )
    }

    static func storyButtonPressed(id: Int, position: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Story button pressed",
            parameters: [
                "id": id,
                "position": position
            ]
        )
    }

    static func storyClosed(id: Int, type: StoryCloseType) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Story closed",
            parameters: [
                "id": id,
                "type": type.rawValue
            ]
        )
    }

    enum StoryCloseType: String {
        case cross
        case swipe
        case automatic
    }

    // MARK: - PersonalDeadlines -

    static let personalDeadlinesScheduleButtonTapped = AmplitudeAnalyticsEvent(
        name: "Personal deadline schedule button pressed"
    )

    // MARK: - Video -

    static let videoPlayerDidEnterBackground = AmplitudeAnalyticsEvent(name: "Video played in background")

    static func videoPlayerDidChangeSpeed(currentSpeed: String, targetSpeed: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Video rate changed",
            parameters: [
                "source": currentSpeed,
                "target": targetSpeed
            ]
        )
    }

    // MARK: - AdaptiveRating -

    static func adaptiveRatingOpened(courseID: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Adaptive rating opened",
            parameters: ["course": courseID]
        )
    }

    // MARK: - Run Code -

    static func runCodeLaunched(stepID: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Run code launched",
            parameters: ["step_id": stepID]
        )
    }

    // MARK: - Continue User Activity -

    static func spotlightUserActivityContinued(deepLinkRoute: DeepLinkRoute) -> AmplitudeAnalyticsEvent {
        let type: String = {
            switch deepLinkRoute {
            case .lesson:
                return "lesson"
            case .notifications:
                return "notifications"
            case .discussions:
                return "discussions"
            case .solutions:
                return "solutions"
            case .profile:
                return "profile"
            case .syllabus:
                return "syllabus"
            case .catalog:
                return "catalog"
            case .home:
                return "home"
            case .course:
                return "course"
            case .coursePromo:
                return "coursePromo"
            }
        }()

        return AmplitudeAnalyticsEvent(
            name: "Spotlight item tapped",
            parameters: ["type": type]
        )
    }
}
