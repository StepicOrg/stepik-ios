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
        
        let simpleAchievement = ChallengeAchievement(slug: "sample_ac", name: "Sample achievement", info: nil, cover: nil)
        simpleAchievement.conditions = { value in return (value as? Int ?? 0) > 3 }
        
        mgr.addSubscriber(for: AchievementEvent.events.level, observer: simpleAchievement)
        mgr.storedAchievements.append(simpleAchievement)
        
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
            if observer.notify(event: event) {
                print("\(observer.attachedAchievement.slug) unlocked!")
                //let achievement = observer.attachedAchievement
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
