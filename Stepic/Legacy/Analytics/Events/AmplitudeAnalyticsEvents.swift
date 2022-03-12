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
        var parameters: [String: Any] = [
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
        case siriShortcut = "ios_siri_shortcut"
    }

    static func courseBuyPressed(
        id: Int,
        source: CourseBuySource,
        isWishlisted: Bool,
        promoCode: String?
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course pressed",
            parameters: [
                "source": source.rawValue,
                "course": id,
                "is_wishlisted": isWishlisted,
                "promo": promoCode as Any
            ]
        )
    }

    enum CourseBuySource: String {
        case courseWidget = "course_widget"
        case courseScreen = "course_screen"
        case demoLessonDialog = "demo_lesson_dialog"
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

    static func courseBuyCoursePromoStartPressed(id: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course promo start pressed",
            parameters: ["course": id]
        )
    }

    static func courseBuyCoursePromoSuccess(id: Int, promoCode: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course promo success",
            parameters: [
                "course": id,
                "promo": promoCode
            ]
        )
    }

    static func courseBuyCoursePromoFailure(id: Int, promoCode: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course promo failure",
            parameters: [
                "course": id,
                "promo": promoCode
            ]
        )
    }

    static func courseBuyCourseIAPFlowStart(
        id: Int,
        source: CourseBuySource,
        isWishlisted: Bool,
        promoCode: String?
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course IAP flow start",
            parameters: [
                "course": id,
                "source": source.rawValue,
                "is_wishlisted": isWishlisted,
                "promo": promoCode as Any
            ]
        )
    }

    static func courseBuyCourseIAPFlowSuccess(
        id: Int,
        source: CourseBuySource,
        isWishlisted: Bool,
        promoCode: String?
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course IAP flow success",
            parameters: [
                "course": id,
                "source": source.rawValue,
                "is_wishlisted": isWishlisted,
                "promo": promoCode as Any
            ]
        )
    }

    static func courseBuyCourseIAPFlowFailure(
        id: Int,
        errorType: String,
        errorDescription: String?
    ) -> AmplitudeAnalyticsEvent {
        var parameters: [String : Any] = [
            "course": id,
            "type": errorType
        ]

        if let errorDescription = errorDescription {
            parameters["message"] = errorDescription
        }

        return AmplitudeAnalyticsEvent(name: "Buy course IAP flow failure", parameters: parameters)
    }

    static func courseBuyCourseVerificationSuccess(
        id: Int,
        source: CourseBuySource,
        isWishlisted: Bool,
        promoCode: String?
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Buy course verification success",
            parameters: [
                "course": id,
                "source": source.rawValue,
                "is_wishlisted": isWishlisted,
                "promo": promoCode as Any
            ]
        )
    }

    static func courseBuyCourseVerificationFailure(
        id: Int,
        errorType: String,
        errorDescription: String?
    ) -> AmplitudeAnalyticsEvent {
        var parameters: [String : Any] = [
            "course": id,
            "type": errorType
        ]

        if let errorDescription = errorDescription {
            parameters["message"] = errorDescription
        }

        return AmplitudeAnalyticsEvent(name: "Buy course verification failure", parameters: parameters)
    }

    static func courseRestoreCoursePurchasePressed(
        id: Int,
        source: CourseRestorePurchaseSource
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Restore course purchase pressed",
            parameters: [
                "course": id,
                "source": source.rawValue
            ]
        )
    }

    enum CourseRestorePurchaseSource: String {
        case buyCourseDialog = "buy_course_dialog"
        case courseScreen = "course_screen"
    }

    // MARK: - Course Search -

    static func courseContentSearchScreenOpened(id: Int, title: String?) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course content search screen opened",
            parameters: [
                "course": id,
                "title": title as Any
            ]
        )
    }

    static func courseContentSearched(
        id: Int,
        title: String?,
        query: String,
        suggestion: String?
    ) -> AmplitudeAnalyticsEvent {
        var parameters: [String: Any] = [
            "course": id,
            "title": title as Any,
            "query": query
        ]

        if let suggestion = suggestion {
            parameters["suggestion"] = suggestion
        }

        return AmplitudeAnalyticsEvent(name: "Course content searched", parameters: parameters)
    }

    static func courseContentSearchResultClicked(
        id: Int,
        title: String?,
        query: String,
        suggestion: String?,
        type: CourseContentSearchResultClickType,
        stepID: Int?
    ) -> AmplitudeAnalyticsEvent {
        var parameters: [String: Any] = [
            "course": id,
            "title": title as Any,
            "query": query,
            "type": type.rawValue,
            "step": stepID as Any
        ]

        if let suggestion = suggestion {
            parameters["suggestion"] = suggestion
        }

        return AmplitudeAnalyticsEvent(name: "Course content search result clicked", parameters: parameters)
    }

    enum CourseContentSearchResultClickType: String {
        case step
        case comment
        case user
    }

    // MARK: - Course News -

    static func courseNewsScreenOpened(id: Int, title: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course news screen opened",
            parameters: [
                "course": id,
                "title": title
            ]
        )
    }

    // MARK: - Course Benefits -

    static func courseBenefitsScreenOpened(id: Int, title: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course benefits screen opened",
            parameters: [
                "course": id,
                "course_title": title
            ]
        )
    }

    static func courseBenefitClicked(
        benefitID: Int,
        status: String,
        courseID: Int,
        courseTitle: String
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course benefit clicked",
            parameters: [
                "benefit": benefitID,
                "status": status,
                "course": courseID,
                "course_title": courseTitle
            ]
        )
    }

    static func courseBenefitsSummaryClicked(
        id: Int,
        title: String,
        expanded: Bool
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course benefits summary clicked",
            parameters: [
                "course": id,
                "course_title": title,
                "expanded": expanded
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

    // MARK: - Review -

    static let reviewSelectDifferentSubmissionClicked = AmplitudeAnalyticsEvent(
        name: "Review Select Different Submission"
    )

    static let reviewSendCurrentSubmissionClicked = AmplitudeAnalyticsEvent(name: "Review Send Current Submission")

    static let reviewSolveAgainClicked = AmplitudeAnalyticsEvent(name: "Review Solve Again")

    static let reviewQuizTryAgainClicked = AmplitudeAnalyticsEvent(name: "Review Quiz Try Again")

    static let reviewStartReviewClicked = AmplitudeAnalyticsEvent(name: "Review Start Review")

    static let reviewViewReviewClicked = AmplitudeAnalyticsEvent(name: "Review View Review")

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

    static func streakNotificationShown(type: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Streak notification shown",
            parameters: ["type": type]
        )
    }

    static func streakNotificationClicked(type: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Streak notification clicked",
            parameters: ["type": type]
        )
    }

    static func retentionNotificationShown(day: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Retention notification shown",
            parameters: ["day": day]
        )
    }

    static func retentionNotificationClicked(day: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Retention notification clicked",
            parameters: ["day": day]
        )
    }

    static func personalDeadlinesAppNotificationShown(
        courseID: Int,
        hoursBeforeDeadline: Int
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Personal deadlines app notification shown",
            parameters: [
                "course": courseID,
                "hours": hoursBeforeDeadline
            ]
        )
    }

    static func personalDeadlinesAppNotificationClicked(
        courseID: Int,
        hoursBeforeDeadline: Int
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Personal deadlines app notification clicked",
            parameters: [
                "course": courseID,
                "hours": hoursBeforeDeadline
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

    static func certificatesScreenOpened(
        userID: Int,
        certificateUserState: CertificateUserState
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Certificates screen opened",
            parameters: [
                "user": userID,
                "state": certificateUserState.rawValue
            ]
        )
    }

    static func certificateScreenOpened(
        certificateID: Int,
        courseID: Int,
        userID: Int,
        certificateUserState: CertificateUserState
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Certificate screen opened",
            parameters: [
                "certificate": certificateID,
                "course": courseID,
                "user": userID,
                "state": certificateUserState.rawValue
            ]
        )
    }

    static func certificateShareClicked(
        certificateID: Int,
        courseID: Int,
        userID: Int,
        certificateUserState: CertificateUserState
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Certificate share clicked",
            parameters: [
                "certificate": certificateID,
                "course": courseID,
                "user": userID,
                "state": certificateUserState.rawValue
            ]
        )
    }

    enum CertificateUserState: String {
        case `self` = "self"
        case other
    }

    static func certificateChangeNameClicked(certificateID: Int, courseID: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Certificate change name clicked",
            parameters: [
                "certificate": certificateID,
                "course": courseID
            ]
        )
    }

    static func certificatePDFClicked(
        certificateID: Int,
        courseID: Int,
        userID: Int,
        certificateUserState: CertificateUserState
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Certificate pdf clicked",
            parameters: [
                "certificate": certificateID,
                "course": courseID,
                "user": userID,
                "state": certificateUserState.rawValue
            ]
        )
    }

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

    static let deleteAccountClicked = AmplitudeAnalyticsEvent(name: "Delete account clicked")

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
        case certificate(id: Int)
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
            case .certificate:
                return "certificate"
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
            case .certificate(let id):
                return ["id": id]
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

    static func writeCourseReviewPressed(
        courseID: Int,
        courseTitle: String,
        source: CourseReviewSource
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Create course review pressed",
            parameters: [
                "course": courseID,
                "title": courseTitle,
                "source": source.rawValue
            ]
        )
    }

    static func editCourseReviewPressed(
        courseID: Int,
        courseTitle: String,
        source: CourseReviewSource
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Edit course review pressed",
            parameters: [
                "course": courseID,
                "title": courseTitle,
                "source": source.rawValue
            ]
        )
    }

    static func courseReviewCreated(courseID: Int, rating: Int, source: CourseReviewSource) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course review created",
            parameters: [
                "course": courseID,
                "rating": rating,
                "source": source.rawValue
            ]
        )
    }

    static func courseReviewUpdated(
        courseID: Int,
        fromRating: Int,
        toRating: Int,
        source: CourseReviewSource
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course review updated",
            parameters: [
                "course": courseID,
                "from_rating": fromRating,
                "to_rating": toRating,
                "source": source.rawValue
            ]
        )
    }

    static func courseReviewDeleted(courseID: Int, rating: Int, source: CourseReviewSource) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Course review deleted",
            parameters: [
                "course": courseID,
                "rating": rating,
                "source": source.rawValue
            ]
        )
    }

    enum CourseReviewSource: String {
        case courseReviews = "course_reviews"
        case userReviews = "user_reviews"
    }

    static func userCourseReviewsScreenOpened(
        userID: Int,
        userAccountState: UserCourseReviewsUserAccountState
    ) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "User course reviews screen opened",
            parameters: [
                "id": userID,
                "state": userAccountState.rawValue
            ]
        )
    }

    enum UserCourseReviewsUserAccountState: String {
        case other
        case anonymous
        case authorized = "self"
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

    static func videoPlayerDidChangeSpeed(source: String, target: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Video rate changed",
            parameters: [
                "source": source,
                "target": target
            ]
        )
    }

    static func videoPlayerQualityChanged(source: String, target: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Video quality changed",
            parameters: [
                "source": source,
                "target": target
            ]
        )
    }

    static func videoPlayerControlClicked(_ sender: VideoPlayerControlType) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Video player control clicked",
            parameters: [
                "action": sender.rawValue
            ]
        )
    }

    enum VideoPlayerControlType: String {
        case previos
        case rewind
        case forward
        case next
        case seekBack = "seek_back"
        case seekForward = "seek_forward"
        case doubleClickLeft = "double_click_left"
        case doubleClickRight = "double_click_right"
        case play
        case pause
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

    // MARK: Home Screen Quick Actions

    static func applicationShortcutItemTriggered(type: String) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Home screen quick action triggered",
            parameters: ["type": type]
        )
    }

    // MARK: Siri Shortcuts

    static func siriShortcutContinued(type: SiriShortcutUserActivityType) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Siri shortcut triggered",
            parameters: ["type": type.rawValue]
        )
    }

    enum SiriShortcutUserActivityType: String {
        case continueLearning = "continue_learning"
    }

    // MARK: - Home Screen Widget -

    static let homeScreenWidgetClicked = AmplitudeAnalyticsEvent(name: "Home screen widget clicked")

    static func homeScreenWidgetAdded(size: Int) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Home screen widget added",
            parameters: ["size": size]
        )
    }

    // MARK: - UserCourses -

    static let myCoursesScreenOpened = AmplitudeAnalyticsEvent(name: "My courses screen opened")

    static func myCoursesScreenTabOpened(tab: UserCourses.Tab) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "My courses screen tab opened",
            parameters: [
                "tab": tab.rawValue
            ]
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

    // MARK: - Finished Steps -

    static func finishedStepsScreenOpened(course: Course) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Finished steps screen opened",
            parameters: [
                "course": course.id,
                "title": course.title,
                "complete_rate": course.progress?.completeRate ?? 0
            ]
        )
    }

    static func finishedStepsSharePressed(course: Course) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Finished steps share pressed",
            parameters: [
                "course": course.id,
                "title": course.title,
                "complete_rate": course.progress?.completeRate ?? 0
            ]
        )
    }

    static func finishedStepsViewCertificatePressed(course: Course) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Finished steps view certificate pressed",
            parameters: [
                "course": course.id,
                "title": course.title,
                "complete_rate": course.progress?.completeRate ?? 0
            ]
        )
    }

    static func finishedStepsBackToAssignmentsPressed(course: Course) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Finished steps back to assignments pressed",
            parameters: [
                "course": course.id,
                "title": course.title,
                "complete_rate": course.progress?.completeRate ?? 0
            ]
        )
    }

    static func finishedStepsFindNewCoursePressed(course: Course) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Finished steps find new course pressed",
            parameters: [
                "course": course.id,
                "title": course.title,
                "complete_rate": course.progress?.completeRate ?? 0
            ]
        )
    }

    static func finishedStepsLeaveReviewPressed(course: Course) -> AmplitudeAnalyticsEvent {
        AmplitudeAnalyticsEvent(
            name: "Finished steps leave review pressed",
            parameters: [
                "course": course.id,
                "title": course.title,
                "complete_rate": course.progress?.completeRate ?? 0
            ]
        )
    }

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
