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

    static func courseJoined(
        source: CourseSubscriptionSource,
        id: Int,
        title: String,
        isWishlisted: Bool? = nil
    ) -> AmplitudeAnalyticsEvent {
        var parameters: [String : Any] = [
            "source": source.rawValue,
            "course": id,
            "title": title
        ]

        if let isWishlisted = isWishlisted {
            parameters["is_wishlisted"] = isWishlisted
        }

        return AmplitudeAnalyticsEvent(name: "Course joined", parameters: parameters)
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

    static func courseContinuePressed(
        id: Int,
        title: String,
        source: CourseContinueSource,
        viewSource: CourseViewSource
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Continue course pressed",
            parameters: [
                "course": id,
                "title": title,
                "source": source.rawValue,
                "view_source": viewSource.name
            ]
        )
    }

    enum CourseContinueSource: String {
        case courseWidget = "course_widget"
        case homeWidget = "home_widget"
        case courseScreen = "course_screen"
        case homeScreenWidget = "ios_home_screen_widget"
        case applicationShortcut = "ios_application_shortcut"
    }

    static func courseBuyPressed(source: CourseBuySource, id: Int, isWishlisted: Bool) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course pressed",
            parameters: [
                "source": source.rawValue,
                "course": id,
                "is_wishlisted": isWishlisted
            ]
        )
    }

    enum CourseBuySource: String {
        case courseWidget = "course_widget"
        case courseScreen = "course_screen"
    }

    static func courseBuyReceiptRefreshed(id: Int, successfully: Bool) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course receipt refreshed",
            parameters: [
                "course": id,
                "result": successfully ? "success" : "error"
            ]
        )
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

    static func profileScreenOpened(state: ProfileScreenOpenState) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Profile screen opened",
            parameters: [
                "state": state.rawValue
            ]
        )
    }

    enum ProfileScreenOpenState: String {
        case anonymous
        case `self`
        case other
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

    // MARK: - Content Language -

    static func contentLanguageChanged(
        _ contentLanguage: ContentLanguage,
        source: ContentLanguageChangeSource
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Content language changed",
            parameters: [
                "language": contentLanguage.languageString,
                "source": source.rawValue
            ]
        )
    }

    enum ContentLanguageChangeSource: String {
        case catalog
        case settings
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
        case visitedCourses
        case downloads
        case fastContinue
        case search(query: String)
        case catalogBlock(id: Int)
        case recommendation
        case collection(id: Int)
        case query(courseListType: CourseListType)
        case story(id: Int)
        case deepLink(url: String)
        case widgetExtension(url: String)
        case notification
        case profile(id: Int)
        case userCoursesReviews
        case wishlist
        case unknown

        var name: String {
            switch self {
            case .myCourses:
                return "my_courses"
            case .visitedCourses:
                return "visited_courses"
            case .downloads:
                return "downloads"
            case .fastContinue:
                return "fast_continue"
            case .search:
                return "search"
            case .catalogBlock:
                return "catalog_block"
            case .recommendation:
                return "recommendation"
            case .collection:
                return "collection"
            case .query:
                return "query"
            case .story:
                return "story"
            case .deepLink:
                return "deeplink"
            case .widgetExtension:
                return "widget_extension"
            case .notification:
                return "notification"
            case .profile:
                return "profile"
            case .userCoursesReviews:
                return "user_courses_reviews"
            case .wishlist:
                return "wishlist"
            case .unknown:
                return "unknown"
            }
        }

        var params: [String: Any]? {
            switch self {
            case .myCourses,
                 .visitedCourses,
                 .downloads,
                 .fastContinue,
                 .notification,
                 .recommendation,
                 .userCoursesReviews,
                 .wishlist,
                 .unknown:
                return nil
            case .search(let query):
                return ["query": query]
            case .catalogBlock(let id):
                return ["id": id]
            case .collection(let id):
                return ["collection": id]
            case .profile(let id):
                return ["profile": id]
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
            case .deepLink(let url), .widgetExtension(let url):
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

    static func storyOpened(id: Int, source: StoryOpenSource) -> AmplitudeAnalyticsEvent {
        var parameters: [String: Any] = [
            "id": id,
            "source": source.name
        ]

        if case .deeplink(let path) = source {
            parameters["deeplink_url"] = path
        }

        return AmplitudeAnalyticsEvent(name: "Story opened", parameters: parameters)
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

    static func storyReactionPressed(id: Int, position: Int, reaction: StoryReaction) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Story reaction pressed",
            parameters: [
                "id": id,
                "position": position,
                "reaction": reaction.rawValue
            ]
        )
    }

    static func storyFeedbackPressed(id: Int, position: Int, feedback: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Story feedback pressed",
            parameters: [
                "id": id,
                "position": position,
                "feedback": feedback
            ]
        )
    }

    // MARK: - PersonalDeadlines -

    static let personalDeadlinesScheduleButtonTapped = AmplitudeAnalyticsEvent(
        name: "Personal deadline schedule button pressed"
    )

    // MARK: - Video -

    static let videoPlayerDidPlayInBackground = AmplitudeAnalyticsEvent(name: "Video played in background")

    static let videoPlayerDidStartPictureInPicture = AmplitudeAnalyticsEvent(name: "Video played in picture-in-picture")

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
            case .course:
                return "course"
            default:
                return "unknown"
            }
        }()

        return AmplitudeAnalyticsEvent(
            name: "Spotlight item tapped",
            parameters: ["type": type]
        )
    }

    // MARK: - Home Screen Quick Actions -

    static func shortcutItemTriggered(type: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Home screen quick action triggered",
            parameters: ["type": type]
        )
    }

    // MARK: - Home Screen Widget -

    static let homeScreenWidgetClicked = AmplitudeAnalyticsEvent(name: "Home screen widget clicked")

    static func homeScreenWidgetAdded(size: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Home screen widget added",
            parameters: ["size": size]
        )
    }

    // MARK: - Wishlist -

    static func wishlistCourseAdded(
        id: Int,
        title: String,
        isPaid: Bool,
        viewSource: CourseViewSource
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course wishlist added",
            parameters: [
                "course": id,
                "title": title,
                "is_paid": isPaid,
                "source": viewSource.name
            ]
        )
    }

    static func wishlistCourseRemoved(
        id: Int,
        title: String,
        isPaid: Bool,
        viewSource: CourseViewSource
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course wishlist removed",
            parameters: [
                "course": id,
                "title": title,
                "is_paid": isPaid,
                "source": viewSource.name
            ]
        )
    }

    static let wishlistScreenOpened = AmplitudeAnalyticsEvent(name: "Wishlist screen opened")

    // MARK: - UserCourse -

    static func userCourseActionMade(
        _ action: CourseInfo.UserCourseAction,
        course: Course,
        viewSource: CourseViewSource
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "User course action",
            parameters: [
                "action": action.analyticName,
                "course": course.id,
                "title": course.title,
                "is_paid": course.isPaid,
                "source": viewSource.name
            ]
        )
    }
}

fileprivate extension CourseInfo.UserCourseAction {
    var analyticName: String {
        switch self {
        case .favoriteAdd:
            return "favorite_add"
        case .favoriteRemove:
            return "favorite_remove"
        case .archiveAdd:
            return "archive_add"
        case .archiveRemove:
            return "archive_remove"
        }
    }
}
