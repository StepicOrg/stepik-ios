//
//  AnalyticsEvents.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

struct AnalyticsEvents {
    
    struct Logout {
        static let clicked = "clicked_logout"
    }
        
    struct SignIn {
        static let onLaunchScreen = "clicked_SignIn_on_launch_screen"
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
    
    struct SignUp {
        static let onLaunchScreen = "clicked_SignUp_on_launch_screen"
        static let onSignUpScreen = "click_registration_with_interaction_type"
        static let nextButton = "click_registration_send_ime"
        struct Fields {
            static let tap = "tap_on_fields_registration"
            static let typing = "typing_text_fields_registration"
        }
    }
    
    struct Login {
        static let success = "success_login"
    }
    
    struct Syllabus {
        static let shared = "share_syllabus_clicked"
    }
    
    struct Units {
        static let shared = "share_units_clicked"
    }
    
    struct Section {
        static let cache = "clicked_cache_section"
        static let cancel = "clicked_cancel_section"
        static let delete = "clicked_delete_cached_section"
    }
    
    struct Unit {
        static let cache = "clicked_cache_unit"
        static let cancel = "clicked_cancel_unit"
        static let delete = "clicked_delete_cached_unit"
    }
    
    struct Downloads {
        static let clear = "clicked_clear_cache"
        static let acceptedClear = "clicked_accepted_clear_cache"
    }
    
    struct CourseOverview {
        static let shared = "share_course_clicked"
        struct JoinPressed {
            static let anonymous = "join_course_anonymous"
            static let signed = "join_course_signed"
        }
    }
    
    struct Step {        
        struct Submission {
            static let submit = "clicked_submit"
            static let newAttempt = "clicked_generate_new_attempt"
            static let solveInWebPressed = "clicked_solve_in_web"
        }
        
        static let hasRestrictions = "step_with_submission_restriction"
        static let opened = "step_type_opened"
    }
    
    struct VideoPlayer {
        static let rateChanged = "video_rate_changed"
        static let qualityChanged = "video_quality_changed"
    }
    
    struct Discussion {
        static let liked = "discussion_liked"
        static let unliked = "discussion_unliked"
        static let abused = "discussion_abused"
    }
    
    struct DeepLink {
        static let step = "deeplink_step"
        static let syllabus = "deeplink_syllabus"
        static let course = "deeplink_course"
        static let section = "deeplink_section"
    }
    
    struct Tabs {
        static let myCoursesClicked = "main_choice_my_courses"
        static let findCoursesClicked = "main_choice_find_courses"
        static let downloadsClicked = "main_choice_downloads"
    }
    
    struct Token {
        static let requestedNotNilToken = "token_requested_not_nil"
    }
    
    struct Streaks {
        static let preferencesOn = "streak_notification_pref_on"
        static let preferencesOff = "streak_notification_pref_off"
        struct Suggestion {
            static func fail(_ index: Int) -> String {
                return "streak_suggestion_\(index)_fail"
            }
            static func success(_ index: Int) -> String {
                return "streak_suggestion_\(index)_success"
            }
        }
        static let notificationOpened = "streak_notification_opened"
    }
    
    struct App {
        static let opened = "app_opened"
    }
    
    struct Errors {
        static let tokenRefresh = "error_token_refresh"
    }
    
    struct Continue {
        static let sectionsOpened = "continue_section_opened"
        static let stepOpened = "continue_step_opened"
    }
}
