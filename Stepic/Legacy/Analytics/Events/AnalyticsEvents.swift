import Foundation

// Describes Firebase and AppMetrica analytics events.
extension AnalyticsEvent {
    // MARK: - App -

    static let applicationDidBecomeActive = AnalyticsEvent(name: "app_opened")

    // MARK: - Notifications -

    static func notificationsMarkAllAsReadClicked(badgeUnreadCount: Int) -> AnalyticsEvent {
        AnalyticsEvent(name: "notifications_mark_all_as_read", parameters: ["badge": badgeUnreadCount])
    }

    static func notificationsMarkAsReadClicked(source: NotificationsMarkAsReadActionSource) -> AnalyticsEvent {
        AnalyticsEvent(name: "notifications_mark_as_read", parameters: ["action": source.rawValue])
    }

    enum NotificationsMarkAsReadActionSource: String {
        case button
        case link
    }

    // MARK: - Adaptive -

    static let adaptiveStepSubmissionCreated = AnalyticsEvent(name: "adaptive_submission_created")
    static let adaptiveStepCorrectAnswer = AnalyticsEvent(name: "adaptive_correct_answer")
    static let adaptiveStepWrongAnswer = AnalyticsEvent(name: "adaptive_wrong_answer")
    static let adaptiveStepRetryAnswer = AnalyticsEvent(name: "adaptive_retry_answer")

    static let adaptiveOnboardingFinished = AnalyticsEvent(name: "adaptive_onboarding_finished")

    static func adaptiveReactionEasy(status: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "adaptive_reaction_easy", parameters: ["status": status])
    }

    static func adaptiveReactionHard(status: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "adaptive_reaction_hard", parameters: ["status": status])
    }

    // MARK: - PersonalDeadlines -

    static let personalDeadlineModeOpened = AnalyticsEvent(name: "personal_deadline_mode_opened")
    static let personalDeadlineModeClosed = AnalyticsEvent(name: "personal_deadline_mode_closed")

    static func personalDeadlineModeChosen(weeklyLoadHours: Int) -> AnalyticsEvent {
        AnalyticsEvent(name: "personal_deadline_mode_chosen", parameters: ["hours": weeklyLoadHours])
    }

    static let personalDeadlineChangePressed = AnalyticsEvent(name: "personal_deadline_change_pressed")

    static let personalDeadlineTimeOpened = AnalyticsEvent(name: "personal_deadline_time_opened")
    static let personalDeadlineTimeClosed = AnalyticsEvent(name: "personal_deadline_time_closed")
    static let personalDeadlineTimeSaved = AnalyticsEvent(name: "personal_deadline_time_saved")

    static let personalDeadlineDeleted = AnalyticsEvent(name: "personal_deadline_deleted")

    // MARK: - Code -

    static let codeInputAccessoryHideKeyboardClicked = AnalyticsEvent(name: "code_hide_keyboard")
    static let codeFullscreenClicked = AnalyticsEvent(name: "code_fullscreen_pressed")
    static let codeResetClicked = AnalyticsEvent(name: "code_reset_pressed", parameters: ["size": "standard"])
    static let codeExitFullscreenClicked = AnalyticsEvent(name: "code_exit_fullscreen")

    static func codeInputAccessoryButtonClicked(language: String, symbol: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "code_toolbar_selected",
            parameters: [
                "language": language,
                "symbol": symbol
            ]
        )
    }

    static func codeLanguageChosen(language: CodeLanguage) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "code_language_chosen",
            parameters: [
                "size": "standard",
                "language": language.rawValue
            ]
        )
    }

    // MARK: - Streaks -

    static let streaksPreferencesOn = AnalyticsEvent(name: "streak_notification_pref_on")
    static let streaksPreferencesOff = AnalyticsEvent(name: "streak_notification_pref_off")

    static func streaksNotifySuggestionShown(source: String, trigger: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "streak_suggestion_shown_source_\(source)_trigger_\(trigger)")
    }

    static func streaksSuggestionSucceeded(index: Int) -> AnalyticsEvent {
        AnalyticsEvent(name: "streak_suggestion_\(index)_success")
    }

    static func streaksSuggestionFailed(index: Int) -> AnalyticsEvent {
        AnalyticsEvent(name: "streak_suggestion_\(index)_fail")
    }

    static func streaksNotifySuggestionApproved(source: String, trigger: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "streak_suggestion_approved_source_\(source)_trigger_\(trigger)")
    }

    // MARK: - Profile -

    static let profileSettingsClicked = AnalyticsEvent(name: "main_choice_settings")
    static let profileInteractedWithPinsMap = AnalyticsEvent(name: "pins_map_interaction")

    // MARK: - Step -

    static let stepSubmissionGenerateNewAttemptClicked = AnalyticsEvent(name: "clicked_generate_new_attempt")
    static let stepSubmissionSolveInWebClicked = AnalyticsEvent(name: "clicked_solve_in_web")
    static let stepOpenedSubmissionWithRestriction = AnalyticsEvent(name: "step_with_submission_restriction")

    static func stepSubmissionSubmitClicked(parameters: [String: Any]?) -> AnalyticsEvent {
        AnalyticsEvent(name: "clicked_submit", parameters: parameters)
    }

    // MARK: - Course -

    static let courseShareClicked = AnalyticsEvent(name: "share_course_clicked")

    // MARK: JoinPressed

    static let courseJoinAnonymousUserClicked = AnalyticsEvent(name: "join_course_anonymous")
    static let courseJoinAuthorizedUserClicked = AnalyticsEvent(name: "join_course_signed")

    // MARK: Video

    static let courseDetailVideoClicked = AnalyticsEvent(name: "course_detail_video_clicked")
    static let courseDetailVideoShown = AnalyticsEvent(name: "course_detail_video_shown")

    // MARK: - Login -

    static func loginSucceeded(provider: LoginProvider) -> AnalyticsEvent {
        AnalyticsEvent(name: "success_login", parameters: ["provider": provider.rawValue])
    }

    enum LoginProvider: String {
        case password
        case social
        case registered
    }

    // MARK: - SignIn -

    static func signInClicked(interactionType: LoginInteractionType) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "click_sign_in_with_interaction_type",
            parameters: ["LoginInteractionType": interactionType.rawValue]
        )
    }

    static let clickedSignInOnEmailAuthScreen = AnalyticsEvent(name: "clicked_SignIn_on_email_auth_screen")
    static let clickedSignInNextSignInScreen = AnalyticsEvent(name: "click_sign_in_next_sign_in_screen")
    static let clickedSignInWithEmailOnSocialAuth = AnalyticsEvent(name: "clicked_SignIn_on_launch_screen")

    enum LoginInteractionType: String {
        case button
        case ime
    }

    // MARK: Fields

    static let tapOnFieldsLogin = AnalyticsEvent(name: "tap_on_fields_login")
    static let typingTextFieldsLogin = AnalyticsEvent(name: "typing_text_fields_login")

    // MARK: Social

    static let signInSocialAuthCodeReceived = AnalyticsEvent(name: "Api:auth with social account")

    static func clickedSignInWithSocialProvider(providerName: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "social_login", parameters: ["social": providerName])
    }

    // MARK: - SignUp -

    static let clickedSignUpOnEmailAuthScreen = AnalyticsEvent(name: "clicked_SignUp_on_email_auth_screen")
    static let clickedRegistrationSendIme = AnalyticsEvent(name: "click_registration_send_ime")
    static let clickedSignUpOnSocialAuth = AnalyticsEvent(name: "clicked_SignUp_on_launch_screen")

    static func signUpClicked(interactionType: LoginInteractionType) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "click_registration_with_interaction_type",
            parameters: ["LoginInteractionType": interactionType.rawValue]
        )
    }

    // MARK: Fields

    static let tapOnFieldsRegistration = AnalyticsEvent(name: "tap_on_fields_registration")
    static let typingTextFieldsRegistration = AnalyticsEvent(name: "typing_text_fields_registration")

    // MARK: - Rate -

    static func rateAppClicked(parameters: [String: Any]?) -> AnalyticsEvent {
        AnalyticsEvent(name: "app_rate", parameters: parameters)
    }

    // MARK: Positive

    static func rateAppPositiveStateAppStoreClicked(parameters: [String: Any]?) -> AnalyticsEvent {
        AnalyticsEvent(name: "app_rate_positive_appstore", parameters: parameters)
    }

    static func rateAppPositiveStateLaterClicked(parameters: [String: Any]?) -> AnalyticsEvent {
        AnalyticsEvent(name: "app_rate_positive_later", parameters: parameters)
    }

    // MARK: Negative

    static func rateAppNegativeStateWriteEmailClicked(parameters: [String: Any]?) -> AnalyticsEvent {
        AnalyticsEvent(name: "app_rate_negative_email", parameters: parameters)
    }

    static func rateAppNegativeStateLaterClicked(parameters: [String: Any]?) -> AnalyticsEvent {
        AnalyticsEvent(name: "app_rate_negative_later", parameters: parameters)
    }

    static func rateAppNegativeStateWriteEmailCancelled(parameters: [String: Any]?) -> AnalyticsEvent {
        AnalyticsEvent(name: "app_rate_negative_email_cancelled", parameters: parameters)
    }

    static func rateAppNegativeStateWriteEmailSucceeded(parameters: [String: Any]?) -> AnalyticsEvent {
        AnalyticsEvent(name: "app_rate_negative_email_success", parameters: parameters)
    }

    // MARK: - VideoPlayer -

    static let videoPlayerOpened = AnalyticsEvent(name: "video_player_opened")

    static func videoPlayerVideoQualityChanged(quality: String, deviceModel: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "video_quality_changed",
            parameters: [
                "quality": quality,
                "device": deviceModel
            ]
        )
    }

    // MARK: - Certificates -

    static func certificatesOpenedCertificate(grade: Int, courseName: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "certificates_opened_certificate",
            parameters: [
                "grade": grade,
                "course": courseName
            ]
        )
    }

    static func certificatesPressedShareCertificate(grade: Int, courseName: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "certificates_pressed_share_certificate",
            parameters: [
                "grade": grade,
                "course": courseName
            ]
        )
    }

    // MARK: - DeepLink -

    static func deepLinkCourse(id: Int) -> AnalyticsEvent {
        AnalyticsEvent(name: "deeplink_course", parameters: ["id": id])
    }

    static func deepLinkSection(courseID: Int, moduleID: Int) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "deeplink_section",
            parameters: [
                "course": courseID,
                "module": moduleID
            ]
        )
    }

    static func deepLinkSyllabus(courseID: Int) -> AnalyticsEvent {
        AnalyticsEvent(name: "deeplink_syllabus", parameters: ["id": courseID])
    }

    static func deepLinkDiscussion(lessonID: Int, stepID: Int, discussionID: Int) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "deeplink_discussion",
            parameters: [
                "lesson": lessonID,
                "step": stepID,
                "discussion": discussionID
            ]
        )
    }

    static func deepLinkStep(lessonID: Int, stepID: Int) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "deeplink_step",
            parameters: [
                "lesson": lessonID,
                "step": stepID
            ]
        )
    }

    // MARK: - Continue -

    static let continueLastStepSyllabusOpened = AnalyticsEvent(name: "continue_section_opened")
    static let continueLastStepStepOpened = AnalyticsEvent(name: "continue_step_opened")

    // MARK: - NotificationRequest -

    static func notificationRequestAlertShown(context: NotificationRequestAlertContext) -> AnalyticsEvent {
        AnalyticsEvent(name: "notification_alert_context_\(context.rawValue)_shown")
    }

    static func notificationRequestAlertAccepted(context: NotificationRequestAlertContext) -> AnalyticsEvent {
        AnalyticsEvent(name: "notification_alert_context_\(context.rawValue)_accepted")
    }

    static func notificationRequestAlertRejected(context: NotificationRequestAlertContext) -> AnalyticsEvent {
        AnalyticsEvent(name: "notification_alert_context_\(context.rawValue)_rejected")
    }

    // MARK: - Settings -

    static func settingsSocialNetworkClicked(_ socialNetwork: StepikSocialNetwork) -> AnalyticsEvent {
        AnalyticsEvent(name: "settings_click_social_network", parameters: ["social": socialNetwork.rawValue])
    }

    // MARK: - VideoDownload -

    static let videoDownloadStarted = AnalyticsEvent(name: "video_download_started")
    static let videoDownloadSucceeded = AnalyticsEvent(name: "video_download_succeeded")
    static let videoDownloadFailed = AnalyticsEvent(name: "video_download_failed")

    static func videoDownloadFailed(
        description: String,
        name: String,
        code: Int,
        domain: String,
        reason: VideoDownloadFailReason
    ) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "video_download_failed",
            parameters: [
                "description": description,
                "name": name,
                "code": code,
                "domain": domain,
                "reason": reason.rawValue
            ]
        )
    }

    enum VideoDownloadFailReason: String {
        case other
        case offline
        case cancelled
        case protocolError = "protocol_error"
    }

    // MARK: - Discussion -

    static let discussionLiked = AnalyticsEvent(name: "discussion_liked")
    static let discussionUnliked = AnalyticsEvent(name: "discussion_unliked")
    static let discussionAbused = AnalyticsEvent(name: "discussion_abused")
    static let discussionUnabused = AnalyticsEvent(name: "discussion_unabused")

    // MARK: - Search -

    static let searchCourseCancelled = AnalyticsEvent(name: "search_cancelled")

    // MARK: - Downloads -

    static let downloadsClearCacheClicked = AnalyticsEvent(name: "clicked_clear_cache")
    static let downloadsAcceptedClearCacheClicked = AnalyticsEvent(name: "clicked_accepted_clear_cache")

    // MARK: - Logout -

    static let clickedLogout = AnalyticsEvent(name: "clicked_logout")

    // MARK: - Errors -

    static let errorAdaptiveRatingServer = AnalyticsEvent(name: "error_adaptive_rating_server")
    static let errorAuthInfoNoUserOnInit = AnalyticsEvent(name: "error_AuthInfo_no_user_on_init")
    static let errorUnregisterDeviceInvalidCredentials = AnalyticsEvent(name: "error_unregister_device_credentials")

    static func errorRegisterDevice(message: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "error_register_device", parameters: ["message": message])
    }

    static func errorUnknownAlamofireNetworkError(message: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "unknown_network_error", parameters: ["aferror": message])
    }

    static func errorUnknownFoundationNetworkError(code: Int, description: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "unknown_network_error",
            parameters: ["nserror": "code: \(code), description: \(description)"]
        )
    }

    static func errorsTokenRefresh(message: String?, statusCode: Int?) -> AnalyticsEvent {
        var parameters: [String: Any] = [:]

        if let message = message {
            parameters["message"] = message
        }

        if let statusCode = statusCode {
            parameters["code"] = "\(statusCode)"
        }

        return AnalyticsEvent(name: "error_token_refresh", parameters: parameters)
    }
}
