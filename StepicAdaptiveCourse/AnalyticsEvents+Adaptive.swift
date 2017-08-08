//
//  AnalyticsEvents+Adaptive.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

extension AnalyticsEvents {
    struct Adaptive {
        static let firstOpen = "adaptive_first_open"
        static let onboardingFinished = "adaptive_onboarding_finished"
        struct Step {
            static let correctAnswer = "adaptive_correct_answer"
            static let wrongAnswer = "adaptive_wrong_answer"
            static let retry = "adaptive_retry_answer"
        }
        struct Achievement {
            static let level = "adaptive_achievement_level"
            static let achievement = "adaptive_achievement_achievement"
            static let shareClicked = "adaptive_achievement_share_clicked"
        }
        struct Reaction {
            static let easy = "adaptive_reaction_easy"
            static let hard = "adaptive_reaction_hard"
        }
        static let localNotification = "adaptive_opened_by_local_notification"
    }
}
