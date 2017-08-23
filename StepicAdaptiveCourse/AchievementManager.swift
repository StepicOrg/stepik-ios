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
        banner.duration = 3.5
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
