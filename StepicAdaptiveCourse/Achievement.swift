//
//  Achievement.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 31.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum AchievementType {
    case challenge, progress
}

protocol Achievement: class, AchievementObserver {
    var slug: String { get set }
    var name: String { get set }
    var info: String? { get set }
    var cover: UIImage? { get set }
    
    var type: AchievementType { get set }
    var progressValue: Int { get set }
    var maxProgressValue: Int { get set }
    
    var completed: (() -> ())? { get set }
    
    // (currentProgress, maxProgress, valueFromEvent) -> should update
    var preConditions: ((Int, Int, Int) -> Bool)? { get set }
    // (currentProgress, maxProgress, valueFromEvent) -> new value
    var value: ((Int, Int, Int) -> Int)? { get set }
    // _ -> newProgressValue
    var migration: (() -> Int)? { get set }
    
    var isUnlocked: Bool { get }
    
    init()
    init(slug: String, name: String, info: String?, cover: UIImage?, type: AchievementType, maxProgressValue: Int, migration: (() -> Int)?)
    
    func restore()
    func save()
}

extension Achievement {
    var attachedAchievement: Achievement {
        return self
    }
    
    var isUnlocked: Bool {
        return maxProgressValue == progressValue
    }
    
    init(slug: String, name: String, info: String?, cover: UIImage?, type: AchievementType, maxProgressValue: Int = 1, migration: (() -> Int)? = nil) {
        self.init()
        
        self.slug = slug
        self.name = name
        self.info = info
        self.cover = cover
        self.type = type
        self.maxProgressValue = maxProgressValue
        self.migration = migration
        
        restore()
    }
    
    init() {
        self.init()
        restore()
    }
    
    func restore() {
        if let params = AchievementsHelper.restore(for: slug) {
            progressValue = params.progressValue
        } else {
            progressValue = migration?() ?? 0
            progressValue = min(progressValue, maxProgressValue)
            save()
        }
    }
    
    func save() {
        AchievementsHelper.save(self)
    }
}

final class ChallengeAchievement: Achievement {
    var slug = ""
    var name = ""
    var info: String? = ""
    var cover: UIImage? = nil
    
    var type: AchievementType = .challenge
    var maxProgressValue: Int = 1
    var progressValue: Int = 0
    
    var completed: (() -> ())? = nil
    var preConditions: ((Int, Int, Int) -> Bool)? = nil
    var value: ((Int, Int, Int) -> Int)? = nil
    var migration: (() -> (Int))? = nil
    
    convenience init(slug: String, name: String, info: String?, cover: UIImage?, migration: (() -> Int)?) {
        self.init(slug: slug, name: name, info: info, cover: cover, type: .challenge, maxProgressValue: 1, migration: migration)
    }
    
    func notify(event: AchievementEvent) -> Bool {
        let cond = (preConditions?(progressValue, maxProgressValue, event.value) ?? true) && progressValue == 0
        if cond {
            progressValue += 1
            save()
        }
        return cond
    }
}

final class ProgressAchievement: Achievement {
    var slug = ""
    var name = ""
    var info: String? = ""
    var cover: UIImage? = nil
    
    var type: AchievementType = .progress
    var maxProgressValue: Int = 1
    var progressValue: Int = 0
    
    var completed: (() -> ())? = nil
    var preConditions: ((Int, Int, Int) -> Bool)? = nil
    var value: ((Int, Int, Int) -> Int)? = nil
    var migration: (() -> (Int))? = nil
    
    convenience init(slug: String, name: String, info: String?, cover: UIImage?, maxProgressValue: Int, migration: (() -> Int)?) {
        self.init(slug: slug, name: name, info: info, cover: cover, type: .progress, maxProgressValue: maxProgressValue, migration: migration)
    }
    
    func notify(event: AchievementEvent) -> Bool {
        var cond = preConditions?(progressValue, maxProgressValue, event.value) ?? true
        if cond {
            let val = value?(progressValue, maxProgressValue, event.value) ?? progressValue
            
            cond = val >= maxProgressValue
            progressValue = min(maxProgressValue, val)
            save()
        }
        return cond
    }
}
