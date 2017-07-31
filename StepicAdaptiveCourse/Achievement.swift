//
//  Achievement.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 31.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol Achievement: class, AchievementObserver {
    var slug: String { get set }
    var name: String { get set }
    var info: String? { get set }
    var cover: String? { get set }
    
    var hasProgress: Bool { get set }
    var progressValue: Int { get set }
    var maxProgressValue: Int { get set }
    
    var completed: (() -> ())? { get set }
    var conditions: ((Any) -> Bool)? { get set }
    
    init()
    init(slug: String, name: String, info: String?, cover: String?, hasProgress: Bool, maxProgressValue: Int)
    
    func restore()
    func save()
}

extension Achievement {
    var attachedAchievement: Achievement {
        return self
    }
    
    init(slug: String, name: String, info: String?, cover: String?, hasProgress: Bool, maxProgressValue: Int = 1) {
        self.init()
        
        self.slug = slug
        self.name = name
        self.info = info
        self.cover = cover
        self.hasProgress = hasProgress
        self.maxProgressValue = maxProgressValue
        
        restore()
    }
    
    init() {
        self.init()
        restore()
    }
    
    func restore() {
        if let params = AchievementsHelper.restore(for: self.slug) {
            self.progressValue = params.progressValue
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
    var cover: String? = nil
    
    var hasProgress = false
    var maxProgressValue: Int = 1
    var progressValue: Int = 0
    
    var completed: (() -> ())? = nil
    var conditions: ((Any) -> Bool)? = nil
    
    convenience init(slug: String, name: String, info: String?, cover: String?) {
        self.init(slug: slug, name: name, info: info, cover: cover, hasProgress: false, maxProgressValue: 1)
    }
    
    func notify(event: AchievementEvent) -> Bool {
        let cond = (conditions?(event.value) ?? true) && progressValue == 0
        if cond {
            completed?()
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
    var cover: String? = nil
    
    var hasProgress = false
    var maxProgressValue: Int = 1
    var progressValue: Int = 0
    
    var completed: (() -> ())? = nil
    var conditions: ((Any) -> Bool)? = nil
    
    convenience init(slug: String, name: String, info: String?, cover: String?, maxProgressValue: Int) {
        self.init(slug: slug, name: name, info: info, cover: cover, hasProgress: true, maxProgressValue: maxProgressValue)
    }
    
    func notify(event: AchievementEvent) -> Bool {
        var cond = conditions?(event.value) ?? true
        if cond {
            if progressValue == maxProgressValue {
                completed?()
                cond = true
            } else {
                cond = false
                progressValue += 1
            }
            save()
        }
        return cond
    }
}
