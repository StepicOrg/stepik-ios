//
//  AchievementManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 31.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class AchievementManager {
    static let shared = AchievementManager.createAndRegisterAchievements()
    
    var storedAchievements: [Achievement] = []
    private var subscribers: [String: [AchievementObserver]] = [:]
    
    static func createAndRegisterAchievements() -> AchievementManager {
        let mgr = AchievementManager()
        
        let achievement1 = ChallengeAchievement(slug: "level6", name: "Шестой уровень", info: "Достичь шестого уровня", cover: #imageLiteral(resourceName: "badge1"))
        achievement1.preConditions = { _, _, value in return (value as? Int ?? 0) >= 6 }
        mgr.addSubscriber(for: AchievementEvent.events.level, observer: achievement1)
        mgr.storedAchievements.append(achievement1)
        
        let achievement2 = ProgressAchievement(slug: "exp100", name: "100 опыта", info: "Получить 100 опыта", cover: #imageLiteral(resourceName: "badge2"), maxProgressValue: 100)
        achievement2.value = { value in return (value as? Int) ?? 0 }
        mgr.addSubscriber(for: AchievementEvent.events.exp, observer: achievement2)
        mgr.storedAchievements.append(achievement2)
        
        let achievement3 = ProgressAchievement(slug: "exp110", name: "110 опыта", info: "Получить 110 опыта", cover: #imageLiteral(resourceName: "badge2"), maxProgressValue: 110)
        achievement3.value = { value in return (value as? Int) ?? 0 }
        mgr.addSubscriber(for: AchievementEvent.events.exp, observer: achievement3)
        mgr.storedAchievements.append(achievement3)
        
        let achievement4 = ProgressAchievement(slug: "exp10", name: "10 опыта", info: "Получить 10 опыта", cover: #imageLiteral(resourceName: "badge1"), maxProgressValue: 10)
        achievement4.value = { value in return (value as? Int) ?? 0 }
        mgr.addSubscriber(for: AchievementEvent.events.exp, observer: achievement4)
        mgr.storedAchievements.append(achievement4)
        
        return mgr
    }
    
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
                print("\(observer.attachedAchievement.slug) unlocked!")
            }
        }
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
    }
    
    var slug: String {
        switch self {
        case .level(_):
            return events.level
        case .exp(_):
            return events.exp
        }
    }
    
    var value: Any {
        switch self {
        case .level(let value):
            return value
        case .exp(let value):
            return value
        }
    }
    
    case level(value: Int)
    case exp(value: Int)
}
