import Foundation

/// Describes Firebase and AppMetrica analytics events.
struct AnalyticsEvents {
    // MARK: - Logout -

    struct Logout {
        static let clicked = "clicked_logout"
    }

    // MARK: - SignIn -

    struct SignIn {
        static let onSocialAuth = "clicked_SignIn_on_launch_screen"
        static let onEmailAuth = "clicked_SignIn_on_email_auth_screen"
        static let onSignInScreen = "click_sign_in_with_interaction_type"
        static let nextButton = "click_sign_in_next_sign_in_screen"

        struct Fields {
            static let tap = "tap_on_fields_login"
            static let typing = "typing_text_fields_login"
        }

        struct Social {
            static let clicked = "social_login"
            static let codeReceived = "Api:auth with social account"
        }
    }

    // MARK: - SignUp -

    struct SignUp {
        static let onSocialAuth = "clicked_SignUp_on_launch_screen"
        static let onEmailAuth = "clicked_SignUp_on_email_auth_screen"
        static let onSignUpScreen = "click_registration_with_interaction_type"
        static let nextButton = "click_registration_send_ime"

        struct Fields {
            static let tap = "tap_on_fields_registration"
            static let typing = "typing_text_fields_registration"
        }
    }

    // MARK: - Login -

    struct Login {
        static let success = "success_login"
    }

    // MARK: - Syllabus -

    struct Syllabus {
        static let shared = "share_syllabus_clicked"
    }

    // MARK: - Units -

    struct Units {
        static let shared = "share_units_clicked"
    }

    // MARK: - Search -

    struct Search {
        static let selected = "search_selected"
        static let cancelled = "search_cancelled"
    }

    // MARK: - Section -

    struct Section {
        static let cache = "clicked_cache_section"
        static let cancel = "clicked_cancel_section"
        static let delete = "clicked_delete_cached_section"
    }

    // MARK: - Unit -

    struct Unit {
        static let cache = "clicked_cache_unit"
        static let cancel = "clicked_cancel_unit"
        static let delete = "clicked_delete_cached_unit"
    }

    // MARK: - Downloads -

    struct Downloads {
        static let clear = "clicked_clear_cache"
        static let acceptedClear = "clicked_accepted_clear_cache"
    }

    // MARK: - Course -

    struct Course {
        static let shared = "share_course_clicked"
        static let delete = "clicked_delete_cached_course"

        struct JoinPressed {
            static let anonymous = "join_course_anonymous"
            static let signed = "join_course_signed"
        }

        struct Video {
            static let clicked = "course_detail_video_clicked"
            static let shown = "course_detail_video_shown"
        }

        struct Downloads {
            static let deleted = "clicked_delete_cached_course"
        }

        struct Reviews {
            static let opened = "course_reviews_screen_opened"
            static let clickedCreate = "create_course_review_pressed"
            static let clickedEdit = "edit_course_review_pressed"
            static let created = "course_review_created"
            static let updated = "course_review_updated"
            static let deleted = "course_review_deleted"
        }
    }

    // MARK: - Step -

    struct Step {
        struct Submission {
            static let submit = "clicked_submit"
            static let newAttempt = "clicked_generate_new_attempt"
            static let solveInWebPressed = "clicked_solve_in_web"
            static let created = "submission_created"
        }

        static let hasRestrictions = "step_with_submission_restriction"
        static let opened = "step_type_opened"

        struct Edit {
            static let opened = "step_edit_opened"
            static let completed = "step_edit_completed"
        }
    }

    // MARK: - VideoPlayer -

    struct VideoPlayer {
        static let opened = "video_player_opened"
        static let rateChanged = "video_rate_changed"
        static let qualityChanged = "video_quality_changed"
    }

    // MARK: - VideoDownload -

    struct VideoDownload {
        static let started = "video_download_started"
        static let succeeded = "video_download_succeeded"
        static let failed = "video_download_failed"

        enum Reason: String {
            case cancelled
            case offline
            case protocolError = "protocol_error"
            case other
        }
    }

    // MARK: - Discussion -

    struct Discussion {
        static let liked = "discussion_liked"
        static let unliked = "discussion_unliked"
        static let abused = "discussion_abused"
        static let unabused = "discussion_unabused"
    }

    // MARK: - DeepLink -

    struct DeepLink {
        static let step = "deeplink_step"
        static let syllabus = "deeplink_syllabus"
        static let course = "deeplink_course"
        static let section = "deeplink_section"
        static let discussion = "deeplink_discussion"
    }

    // MARK: - Tabs -

    struct Tabs {
        static let myCoursesClicked = "main_choice_my_courses"
        static let findCoursesClicked = "main_choice_find_courses"
        static let downloadsClicked = "main_choice_downloads"
        static let certificatesClicked = "main_choice_certificates"
        static let profileClicked = "main_choice_profile"
        static let notificationsClicked = "main_choice_notifications"
        static let catalogClicked = "main_choice_catalog"
    }

    // MARK: - Streaks -

    struct Streaks {
        static let preferencesOn = "streak_notification_pref_on"
        static let preferencesOff = "streak_notification_pref_off"

        static func notifySuggestionShown(source: String, trigger: String) -> String {
            return "streak_suggestion_shown_source_\(source)_trigger_\(trigger)"
        }

        static func notifySuggestionApproved(source: String, trigger: String) -> String {
            return "streak_suggestion_approved_source_\(source)_trigger_\(trigger)"
        }

        struct Suggestion {
            static func fail(_ index: Int) -> String {
                return "streak_suggestion_\(index)_fail"
            }

            static func success(_ index: Int) -> String {
                return "streak_suggestion_\(index)_success"
            }
        }

        static let notificationOpened = "streak_notification_opened"

        struct LocalNotification {
            static let shown = "streak_local_notification_shown"
            static let opened = "streak_local_notification_opened"
        }

        struct ImproveAlert {
            static let notificationOffered = "streak_improve_alert_notifications_offered"
            static let timeSelected = "streak_improve_alert_time_selected"
            static let timeCancelled = "streak_improve_alert_time_cancelled"
        }
    }

    // MARK: - App -

    struct App {
        static let opened = "app_opened"
        static let firstLaunch = "first_launch_after_install"
    }

    // MARK: - Errors -

    struct Errors {
        static let tokenRefresh = "error_token_refresh"
        static let unregisterDeviceInvalidCredentials = "error_unregister_device_credentials"
        static let registerDevice = "error_register_device"
        static let adaptiveRatingServer = "error_adaptive_rating_server"
        static let authInfoNoUserOnInit = "error_AuthInfo_no_user_on_init"
        static let unknownNetworkError = "unknown_network_error"
    }

    // MARK: - Continue -

    struct Continue {
        static let sectionsOpened = "continue_section_opened"
        static let stepOpened = "continue_step_opened"
    }

    // MARK: - Rate -

    struct Rate {
        static let rated = "app_rate"

        struct Positive {
            static let later = "app_rate_positive_later"
            static let appstore = "app_rate_positive_appstore"
        }

        struct Negative {
            static let later = "app_rate_negative_later"
            static let email = "app_rate_negative_email"

            struct Email {
                static let cancelled = "app_rate_negative_email_cancelled"
                static let success = "app_rate_negative_email_success"
            }
        }
    }

    // MARK: - Certificates -

    struct Certificates {
        static let opened = "certificates_opened_certificate"
        static let shared = "certificates_pressed_share_certificate"
    }

    // MARK: - PeekNPop -

    struct PeekNPop {
        struct Course {
            static let peeked = "3dtouch_course_peeked"
            static let popped = "3dtouch_course_popped"
            static let shared = "3dtouch_course_shared"
        }

        struct Section {
            static let peeked = "3dtouch_section_peeked"
            static let popped = "3dtouch_section_popped"
            static let shared = "3dtouch_section_shared"
        }

        struct Lesson {
            static let peeked = "3dtouch_lesson_peeked"
            static let popped = "3dtouch_lesson_popped"
            static let shared = "3dtouch_lesson_shared"
        }
    }

    // MARK: - Code -

    struct Code {
        static let languageChosen = "code_language_chosen"
        static let fullscreenPressed = "code_fullscreen_pressed"
        static let resetPressed = "code_reset_pressed"
        static let exitFullscreen = "code_exit_fullscreen"
        static let toolbarSelected = "code_toolbar_selected"
        static let hideKeyboard = "code_hide_keyboard"
    }

    // MARK: - Profile -

    struct Profile {
        static let clickSettings = "main_choice_settings"
        static let interactionWithPinsMap = "pins_map_interaction"

        struct Settings {
            static let socialNetworkClick = "settings_click_social_network"
        }
    }

    // MARK: - Notifications -

    struct Notifications {
        static let markAllAsRead = "notifications_mark_all_as_read"
        static let markAsRead = "notifications_mark_as_read"
    }

    // MARK: - NotificationRequest -

    struct NotificationRequest {
        static func shown(context: NotificationRequestAlertContext) -> String {
            return "notification_alert_context_\(context.rawValue)_shown"
        }

        static func accepted(context: NotificationRequestAlertContext) -> String {
            return "notification_alert_context_\(context.rawValue)_accepted"
        }

        static func rejected(context: NotificationRequestAlertContext) -> String {
            return "notification_alert_context_\(context.rawValue)_rejected"
        }
    }

    // MARK: - Onboarding -

    struct Onboarding {
        static let onboardingClosed = "onboarding_closed"
        static let onboardingScreenOpened = "onboarding_screen_opened"
        static let onboardingAction = "onboarding_action"
        static let onboardingComplete = "onboarding_complete"
    }

    // MARK: - Adaptive -

    struct Adaptive {
        static let onboardingFinished = "adaptive_onboarding_finished"

        struct Step {
            static let submission = "adaptive_submission_created"
            static let correctAnswer = "adaptive_correct_answer"
            static let wrongAnswer = "adaptive_wrong_answer"
            static let retry = "adaptive_retry_answer"
        }

        struct Reaction {
            static let easy = "adaptive_reaction_easy"
            static let hard = "adaptive_reaction_hard"
        }
    }

    // MARK: - PersonalDeadlines -

    struct PersonalDeadlines {
        struct Widget {
            static let shown = "personal_deadlines_widget_shown"
            static let clicked = "personal_deadlines_widget_clicked"
            static let hidden = "personal_deadlines_widget_hidden"
        }

        struct Mode {
            static let opened = "personal_deadline_mode_opened"
            static let chosen = "personal_deadline_mode_chosen"
            static let closed = "personal_deadline_mode_closed"
        }

        struct EditSchedule {
            static let changePressed = "personal_deadline_change_pressed"

            struct Time {
                static let opened = "personal_deadline_time_opened"
                static let closed = "personal_deadline_time_closed"
                static let saved = "personal_deadline_time_saved"
            }
        }

        static let deleted = "personal_deadline_deleted"
        static let notSupportedNotification = "personal_deadline_not_supported_notification_scheduled"
    }

    // MARK: - Settings -

    struct Settings {
        static let fontSizeSelected = "font_size_selected"
    }
}
