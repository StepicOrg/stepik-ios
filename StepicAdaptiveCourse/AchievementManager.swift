//
//  AchievementManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 31.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import NotificationBannerSwift

protocol AchievementManagerDelegate: class {
    func achievementUnlocked(for achievement: Achievement)
}

class AchievementManager {
    weak var delegate: AchievementManagerDelegate?
    
    var storedAchievements: [Achievement] = []
    fileprivate var subscribers: [String: [AchievementObserver]] = [:]
    
    func addSubscriber(for event: String, observer: AchievementObserver) {
        if subscribers[event] == nil {
            subscribers[event] = []
        }
        subscribers[event]?.append(observer)
    }
    
    func fireEvent(_ event: AchievementEvent) {
        print("achievements: fired event \(event)")
        (subscribers[event.slug] ?? []).forEach { observer in
            if !observer.attachedAchievement.isUnlocked && observer.notify(event: event) {
                showNotification(for: observer.attachedAchievement)
            }
        }
    }
    
    func showNotification(for achievement: Achievement) {
        let notificationView = UINib(nibName: "AchievementNotificationView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AchievementNotificationView
        notificationView.updateInfo(name: achievement.name, cover: achievement.cover ?? Images.boundedStepicIcon)
        
        let banner = NotificationBanner(customView: notificationView)
        banner.onTap = { [weak self] in
            self?.delegate?.achievementUnlocked(for: achievement)
        }
        banner.onSwipeUp = {
            banner.dismiss()
        }
        banner.show()
    }
}

protocol AchievementObserver: class {
    var attachedAchievement: Achievement { get }
    func notify(event: AchievementEvent) -> Bool
}

enum AchievementEvent {
    struct events {
        static let level = "level"
        static let exp = "exp"
        static let onboarding = "onboarding"
        static let streak = "streak"
        static let days = "days"
        static let share = "share"
    }
    
    var slug: String {
        switch self {
        case .level(_): return events.level
        case .exp(_): return events.exp
        case .onboarding: return events.onboarding
        case .streak(_): return events.streak
        case .days(_): return events.days
        case .share: return events.share
        }
    }
    
    var value: Int {
        switch self {
        case .level(let value): return value
        case .exp(let value): return value
        case .onboarding: return 0
        case .streak(let value): return value
        case .days(let value): return value
        case .share: return 0
        }
    }
    
    case level(value: Int)
    case exp(value: Int)
    case onboarding
    case streak(value: Int)
    case days(value: Int)
    case share
}

extension AchievementManager {
    static let shared = AchievementManager.createAndRegisterAchievements()
    
    static func createAndRegisterAchievements() -> AchievementManager {
        let mgr = AchievementManager()
        
        let isOnboardingPassed = UserDefaults.standard.bool(forKey: "isOnboardingShown")
        let curRating = RatingManager.shared.rating
        let curStreak = StatsManager.shared.maxStreak
        let curLevel = RatingHelper.getLevel(for: curRating)
        
        typealias ChallengeAchievementDescription = (slug: String, name: String, info: String, cover: UIImage, pre: ((Int, Int, Int) -> (Bool))?, migration: (() -> Int)?, event: String)
        typealias ProgressAchievementDescription = (slug: String, name: String, info: String, cover: UIImage, maxValue: Int, pre: ((Int, Int, Int) -> (Bool))?, value: ((Int, Int, Int) -> Int)?, migration: (() -> Int)?, event: String)
        
        let challengeAchievements: [ChallengeAchievementDescription] = [
            (slug: "onboarding", name: "Первые шаги", info: "Пройти обучение", cover: #imageLiteral(resourceName: "badge1"), pre: nil, migration: { return isOnboardingPassed ? 1 : 0 }, event: AchievementEvent.events.onboarding),
            (slug: "share", name: "Общительный", info: "Поделиться любым своим достижением", cover: #imageLiteral(resourceName: "badge1"), pre: nil, migration: nil, event: AchievementEvent.events.share),
        ]
        
        func createExpAchievement(name: String, exp: Int, cover: UIImage) -> ProgressAchievementDescription {
            return (slug: "exp\(exp)",
                    name: "\(name)",
                    info: "Получить \(exp) опыта",
                    cover: cover,
                    maxValue: exp,
                    pre: nil,
                    value: { cur, _, value in return cur + value },
                    migration: { return curRating },
                    event: AchievementEvent.events.exp)
        }
        
        func createStreakAchievement(name: String, streak: Int, cover: UIImage) -> ProgressAchievementDescription {
            return (slug: "streak\(streak)",
                name: "\(name)",
                info: "Решить \(streak) заданий с первой попытки",
                cover: cover,
                maxValue: streak,
                pre: { cur, _, value in return value > cur },
                value: { cur, _, value in return max(cur, value) },
                migration: { return curStreak },
                event: AchievementEvent.events.streak)
        }
        
        func createDaysAchievement(name: String, streak: Int, cover: UIImage) -> ProgressAchievementDescription {
            return (slug: "days\(streak)",
                name: "\(name)",
                info: "Решать \(streak) дней подряд",
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
                info: "Достигнуть \(level) уровня",
                cover: cover,
                maxValue: level,
                pre: { cur, _, value in return value > cur },
                value: { cur, _, value in return max(cur, value) },
                migration: { return curLevel },
                event: AchievementEvent.events.level)
        }
        
        let progressAchievements: [ProgressAchievementDescription] = [
            createExpAchievement(name: "Ученик", exp: 10, cover: #imageLiteral(resourceName: "badge1")),
            createExpAchievement(name: "Студент", exp: 100, cover: #imageLiteral(resourceName: "badge1")),
            createExpAchievement(name: "Опытный", exp: 500, cover: #imageLiteral(resourceName: "badge1")),
            createExpAchievement(name: "Профессионал", exp: 5000, cover: #imageLiteral(resourceName: "badge1")),
            createExpAchievement(name: "Гуру", exp: 10000, cover: #imageLiteral(resourceName: "badge1")),
            createStreakAchievement(name: "Комбо", streak: 5, cover: #imageLiteral(resourceName: "badge1")),
            createStreakAchievement(name: "Было просто", streak: 15, cover: #imageLiteral(resourceName: "badge1")),
            createStreakAchievement(name: "В точку", streak: 30, cover: #imageLiteral(resourceName: "badge1")),
            createStreakAchievement(name: "Ясновидящий", streak: 60, cover: #imageLiteral(resourceName: "badge1")),
            createDaysAchievement(name: "Работяга", streak: 2, cover: #imageLiteral(resourceName: "badge1")),
            createDaysAchievement(name: "Трудовая неделя", streak: 5, cover: #imageLiteral(resourceName: "badge1")),
            createDaysAchievement(name: "Зависимый", streak: 10, cover: #imageLiteral(resourceName: "badge1")),
            createDaysAchievement(name: "Стахановец", streak: 14, cover: #imageLiteral(resourceName: "badge1")),
            createDaysAchievement(name: "Герой труда", streak: 30, cover: #imageLiteral(resourceName: "badge1")),
            createLevelAchievement(name: "Знаток", level: 5, cover: #imageLiteral(resourceName: "badge1")),
            createLevelAchievement(name: "Лидер", level: 10, cover: #imageLiteral(resourceName: "badge1"))
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
