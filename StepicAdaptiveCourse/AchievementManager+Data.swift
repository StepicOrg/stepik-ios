//
//  AchievementManager+Data.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

extension AchievementManager {
    static var shared: AchievementManager?

    static func createAndRegisterAchievements(currentRating: Int, currentStreak: Int, currentLevel: Int, isOnboardingPassed: Bool) -> AchievementManager {
        let mgr = AchievementManager()

        typealias ChallengeAchievementDescription = (slug: String, name: String, info: String, cover: UIImage, pre: ((Int, Int, Int) -> (Bool))?, migration: (() -> Int)?, event: String)
        typealias ProgressAchievementDescription = (slug: String, name: String, info: String, cover: UIImage, maxValue: Int, pre: ((Int, Int, Int) -> (Bool))?, value: ((Int, Int, Int) -> Int)?, migration: (() -> Int)?, event: String)

        let challengeAchievements: [ChallengeAchievementDescription] = [
            (slug: "onboarding", name: NSLocalizedString("AdaptiveAchievementFirstStep", comment: ""), info: NSLocalizedString("AdaptiveAchievementFirstStepDesc", comment: ""), cover: #imageLiteral(resourceName: "onboarding"), pre: nil, migration: { return isOnboardingPassed ? 1 : 0 }, event: AchievementEvent.events.onboarding)
        ]

        func createExpAchievement(name: String, exp: Int, cover: UIImage) -> ProgressAchievementDescription {
            return (slug: "exp\(exp)",
                name: "\(name)",
                info: String(format: NSLocalizedString("AdaptiveAchievementExpDesc", comment: ""), "\(exp)"),
                cover: cover,
                maxValue: exp,
                pre: nil,
                value: { cur, _, value in return cur + value },
                migration: { return currentRating },
                event: AchievementEvent.events.exp)
        }

        func createStreakAchievement(name: String, streak: Int, cover: UIImage) -> ProgressAchievementDescription {
            return (slug: "streak\(streak)",
                name: "\(name)",
                info: String(format: NSLocalizedString("AdaptiveAchievementStreakDesc", comment: ""), "\(streak)"),
                cover: cover,
                maxValue: streak,
                pre: { cur, _, value in return value > cur },
                value: { cur, _, value in return max(cur, value) },
                migration: { return currentStreak },
                event: AchievementEvent.events.streak)
        }

        func createDaysAchievement(name: String, streak: Int, cover: UIImage) -> ProgressAchievementDescription {
            return (slug: "days\(streak)",
                name: "\(name)",
                info: String(format: NSLocalizedString("AdaptiveAchievementDaysStreakDesc", comment: ""), "\(streak)"),
                cover: cover,
                maxValue: streak,
                pre: { cur, _, value in return value > cur },
                value: { cur, _, value in return max(cur, value) },
                migration: { return 0 },
                event: AchievementEvent.events.days)
        }

        func createLevelAchievement(name: String, level: Int, cover: UIImage) -> ProgressAchievementDescription {
            return (slug: "level\(level)",
                name: "\(name)",
                info: String(format: NSLocalizedString("AdaptiveAchievementLevelDesc", comment: ""), "\(level)"),
                cover: cover,
                maxValue: level,
                pre: { cur, _, value in return value > cur },
                value: { cur, _, value in return max(cur, value) },
                migration: { return currentLevel },
                event: AchievementEvent.events.level)
        }

        let progressAchievements: [ProgressAchievementDescription] = [
            createExpAchievement(name: NSLocalizedString("AdaptiveAchievementExp1", comment: ""), exp: 10, cover: #imageLiteral(resourceName: "exp1")),
            createExpAchievement(name: NSLocalizedString("AdaptiveAchievementExp2", comment: ""), exp: 100, cover: #imageLiteral(resourceName: "exp2")),
            createExpAchievement(name: NSLocalizedString("AdaptiveAchievementExp3", comment: ""), exp: 500, cover: #imageLiteral(resourceName: "exp3")),
            createExpAchievement(name: NSLocalizedString("AdaptiveAchievementExp4", comment: ""), exp: 5000, cover: #imageLiteral(resourceName: "exp4")),
            createExpAchievement(name: NSLocalizedString("AdaptiveAchievementExp5", comment: ""), exp: 10000, cover: #imageLiteral(resourceName: "exp5")),
            createStreakAchievement(name: NSLocalizedString("AdaptiveAchievementStreak1", comment: ""), streak: 5, cover: #imageLiteral(resourceName: "streak1")),
            createStreakAchievement(name: NSLocalizedString("AdaptiveAchievementStreak2", comment: ""), streak: 15, cover: #imageLiteral(resourceName: "streak2")),
            createStreakAchievement(name: NSLocalizedString("AdaptiveAchievementStreak3", comment: ""), streak: 30, cover: #imageLiteral(resourceName: "streak3")),
            createStreakAchievement(name: NSLocalizedString("AdaptiveAchievementStreak4", comment: ""), streak: 60, cover: #imageLiteral(resourceName: "streak4")),
            createDaysAchievement(name: NSLocalizedString("AdaptiveAchievementDaysStreak1", comment: ""), streak: 2, cover: #imageLiteral(resourceName: "days1")),
            createDaysAchievement(name: NSLocalizedString("AdaptiveAchievementDaysStreak2", comment: ""), streak: 5, cover: #imageLiteral(resourceName: "days2")),
            createDaysAchievement(name: NSLocalizedString("AdaptiveAchievementDaysStreak3", comment: ""), streak: 10, cover: #imageLiteral(resourceName: "days3")),
            createDaysAchievement(name: NSLocalizedString("AdaptiveAchievementDaysStreak4", comment: ""), streak: 14, cover: #imageLiteral(resourceName: "days4")),
            createDaysAchievement(name: NSLocalizedString("AdaptiveAchievementDaysStreak5", comment: ""), streak: 30, cover: #imageLiteral(resourceName: "days5")),
            createLevelAchievement(name: NSLocalizedString("AdaptiveAchievementLevel1", comment: ""), level: 5, cover: #imageLiteral(resourceName: "level1")),
            createLevelAchievement(name: NSLocalizedString("AdaptiveAchievementLevel2", comment: ""), level: 10, cover: #imageLiteral(resourceName: "level2"))
        ]

        for achievementDescription in challengeAchievements {
            let achievement = ChallengeAchievement(slug: achievementDescription.slug, name: achievementDescription.name, info: achievementDescription.info, cover: achievementDescription.cover, migration: achievementDescription.migration)
            mgr.addSubscriber(for: achievementDescription.event, observer: achievement)
            mgr.storedAchievements.append(achievement)
        }

        for achievementDescription in progressAchievements {
            let achievement = ProgressAchievement(slug: achievementDescription.slug, name: achievementDescription.name, info: achievementDescription.info, cover: achievementDescription.cover, maxProgressValue: achievementDescription.maxValue, migration: achievementDescription.migration)
            achievement.preConditions = achievementDescription.pre
            achievement.migration = achievementDescription.migration
            achievement.value = achievementDescription.value
            mgr.addSubscriber(for: achievementDescription.event, observer: achievement)
            mgr.storedAchievements.append(achievement)
        }

        return mgr
    }
}
