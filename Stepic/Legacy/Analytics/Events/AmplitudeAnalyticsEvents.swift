import Foundation

extension AnalyticsEvent {
    // MARK: - Launch -

    static let applicationDidLaunchFirstTime = AmplitudeAnalyticsEvent(name: "Launch first time")

    static func launchSessionStart(
        notificationType: String? = nil,
        sinceLastSession: TimeInterval
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Session start",
            parameters: [
                "notification_type": notificationType as Any,
                "seconds_since_last_session": sinceLastSession
            ]
        )
    }

    // MARK: - Onboarding -

    static func onboardingScreenOpened(screenIndex: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Onboarding screen opened",
            parameters: [
                "screen": screenIndex
            ]
        )
    }

    static func onboardingClosed(screenIndex: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Onboarding closed",
            parameters: [
                "screen": screenIndex
            ]
        )
    }

    static let onboardingCompleted = AmplitudeAnalyticsEvent(name: "Onboarding completed")

    // MARK: - SignIn -

    static func signInLoggedIn(source: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Logged in",
            parameters: [
                "source": source
            ]
        )
    }

    // MARK: - SignUp -

    static func signUpRegistered(source: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Registered",
            parameters: [
                "source": source
            ]
        )
    }

    // MARK: - Course -

    static func courseJoined(source: String, courseID: Int, courseTitle: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course joined",
            parameters: [
                "source": source,
                "course": courseID,
                "title": courseTitle
            ]
        )
    }

    static func courseUnsubscribed(courseID: Int, courseTitle: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course unsubscribed",
            parameters: [
                "course": courseID,
                "title": courseTitle
            ]
        )
    }

    static func courseContinuePressed(
        source: CourseContinueSource,
        courseID: Int,
        courseTitle: String
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Continue course pressed",
            parameters: [
                "source": source.rawValue,
                "course": courseID,
                "title": courseTitle
            ]
        )
    }

    enum CourseContinueSource: String {
        case courseWidget = "course_widget"
        case homeWidget = "home_widget"
    }

    static func courseBuyPressed(source: CourseBuyingSource, courseID: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course pressed",
            parameters: [
                "source": source.rawValue,
                "course": courseID
            ]
        )
    }

    enum CourseBuyingSource: String {
        case courseWidget = "course_widget"
        case courseScreen = "course_screen"
    }

    // MARK: - Steps -

    static func stepsSubmissionMade(
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

    static func stepsStepOpened(stepID: Int, blockName: String, number: Int? = nil) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Step opened",
            parameters: [
                "step": stepID,
                "type": blockName,
                "number": number as Any
            ]
        )
    }

    static func stepsStepEditOpened(stepID: Int, blockName: String, position: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Step edit opened",
            parameters: [
                "step": stepID,
                "type": blockName,
                "number": position
            ]
        )
    }

    static func stepsStepEditCompleted(stepID: Int, blockName: String, position: Int) -> AmplitudeAnalyticsEvent {
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

    static func downloadsDownloadStarted(content: DownloadsContent) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Download started",
            parameters: [
                "content": content.rawValue
            ]
        )
    }

    static func downloadsDownloadCancelled(content: DownloadsContent) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Download cancelled",
            parameters: [
                "content": content.rawValue
            ]
        )
    }

    static func downloadsDownloadDeleted(
        content: DownloadsContent,
        source: DownloadsDeleteDownloadSource
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Download deleted",
            parameters: [
                "content": content.rawValue,
                "source": source.rawValue
            ]
        )
    }

    static func downloadsDeleteDownloadsConfirmationInteracted(
        content: DownloadsContent,
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

    static let downloadsScreenOpened = AmplitudeAnalyticsEvent(name: "Downloads screen opened")

    enum DownloadsContent: String {
        case course
        case section
        case lesson
        case step
    }

    enum DownloadsDeleteDownloadSource: String {
        case syllabus
        case downloads
    }

    // MARK: - Search -

    static let searchCourseStarted = AmplitudeAnalyticsEvent(name: "Course search started")

    static func searchCourseSearched(query: String, position: Int, suggestion: String) -> AmplitudeAnalyticsEvent {
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

    static func notificationsForegroundNotificationReceived(notificationType: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Foreground notification received",
            parameters: [
                "notification_type": notificationType
            ]
        )
    }

    static func notificationsInactiveNotificationReceived(notificationType: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Inactive notification received",
            parameters: [
                "notification_type": notificationType
            ]
        )
    }

    static func notificationsDefaultAlertShown(source: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Default notification alert shown",
            parameters: [
                "source": source
            ]
        )
    }

    static func notificationsDefaultAlertInteracted(source: String, result: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Default notification alert interacted",
            parameters: [
                "source": source,
                "result": result
            ]
        )
    }

    static func notificationsCustomAlertShown(source: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Custom notification alert shown",
            parameters: [
                "source": source
            ]
        )
    }

    static func notificationsCustomAlertInteracted(
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

    static func notificationsPreferencesAlertShown(source: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Preferences notification alert shown",
            parameters: [
                "source": source
            ]
        )
    }

    static func notificationsPreferencesAlertInteracted(source: String, result: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Preferences notification alert interacted",
            parameters: [
                "source": source,
                "result": result
            ]
        )
    }

    static func notificationsPreferencesPushPermissionChanged(isRegistered: Bool) -> AmplitudeAnalyticsEvent {
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
            name: "Category opened ",
            parameters: [
                "category_id": categoryID,
                "category_name_en": categoryNameEn
            ]
        )
    }

    // MARK: - CourseList -

    static let courseListShowAllClicked = AmplitudeAnalyticsEvent(name: "Course list show all clicked")

    // MARK: - Profile -

    static func profileScreenOpened(state: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Profile screen opened",
            parameters: [
                "state": state
            ]
        )
    }

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

    static func achievementsPopupOpened(source: String, kind: String, level: Int? = nil) -> AmplitudeAnalyticsEvent {
        achievementsPopupEvent(name: "Achievement popup opened", source: source, kind: kind, level: level)
    }

    static func achievementsPopupShared(source: String, kind: String, level: Int? = nil) -> AmplitudeAnalyticsEvent {
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

    static func coursePreviewScreenOpened(courseID: Int, courseTitle: String, isPaid: Bool) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course preview screen opened",
            parameters: [
                "course": courseID,
                "title": courseTitle,
                "is_paid": isPaid
            ]
        )
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

    static func courseReviewsWritePressed(courseID: Int, courseTitle: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Create course review pressed",
            parameters: [
                "course": courseID,
                "title": courseTitle
            ]
        )
    }

    static func courseReviewsEditPressed(courseID: Int, courseTitle: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Edit course review pressed",
            parameters: [
                "course": courseID,
                "title": courseTitle
            ]
        )
    }

    static func courseReviewsCreated(courseID: Int, rating: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course review created",
            parameters: [
                "course": courseID,
                "rating": rating
            ]
        )
    }

    static func courseReviewsUpdated(courseID: Int, fromRating: Int, toRating: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course review updated",
            parameters: [
                "course": courseID,
                "from_rating": fromRating,
                "to_rating": toRating
            ]
        )
    }

    static func courseReviewsDeleted(courseID: Int, rating: Int) -> AmplitudeAnalyticsEvent {
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

    static func storiesStoryOpened(id: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Story opened",
            parameters: [
                "id": id
            ]
        )
    }

    static func storiesStoryPartOpened(id: Int, position: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Story part opened",
            parameters: [
                "id": id,
                "position": position
            ]
        )
    }

    static func storiesStoryButtonPressed(id: Int, position: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Story button pressed",
            parameters: [
                "id": id,
                "position": position
            ]
        )
    }

    static func storiesStoryClosed(id: Int, type: StoriesStoryCloseType) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Story closed",
            parameters: [
                "id": id,
                "type": type.rawValue
            ]
        )
    }

    enum StoriesStoryCloseType: String {
        case cross
        case swipe
        case automatic
    }

    // MARK: - PersonalDeadlines -

    static let personalDeadlinesScheduleButtonClicked = AmplitudeAnalyticsEvent(
        name: "Personal deadline schedule button pressed"
    )

    // MARK: - Video -

    static let videoContinuedInBackground = AmplitudeAnalyticsEvent(name: "Video played in background")

    static func videoChangedSpeed(source: String, target: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Video rate changed",
            parameters: [
                "source": source,
                "target": target
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

    static func continueUserActivitySpotlightItemTapped(deepLinkRoute: DeepLinkRoute) -> AmplitudeAnalyticsEvent {
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
