//
//  AdaptiveStatsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol AdaptiveStatsView: class {
    func reload()
    func setProgress(records: [WeekProgressViewData])
    func setAchievements(records: [AchievementViewData])
    func setGeneralStats(currentLevel: Int, bestStreak: Int, currentWeekXP: Int, last7DaysProgress: [Int]?)
}

struct WeekProgressViewData {
    let weekBegin: Date
    let progress: Int
    let isRecord: Bool
}

struct AchievementViewData {
    let name: String
    let info: String
    let type: AchievementType
    let cover: UIImage?
    let isUnlocked: Bool
    let currentProgress: Int
    let maxProgress: Int
}

class AdaptiveStatsPresenter {
    weak var view: AdaptiveStatsView?
    
    fileprivate var ratingManager: RatingManager
    fileprivate var statsManager: StatsManager
    fileprivate var achievementsManager: AchievementManager
    
    init(statsManager: StatsManager, ratingManager: RatingManager, achievementsManager: AchievementManager, view: AdaptiveStatsView) {
        self.view = view
        
        self.statsManager = statsManager
        self.ratingManager = ratingManager
        self.achievementsManager = achievementsManager
    }
    
    func reloadStats() {
        var achievements: [AchievementViewData] = []
        var progressByWeek: [WeekProgressViewData] = []
        
        let currentXP = ratingManager.rating
        let currentLevel = RatingHelper.getLevel(for: currentXP)
        let bestStreak = max(1, statsManager.maxStreak)
        
        // Achievements
        achievementsManager.storedAchievements.forEach({ achievement in
            achievements.append(AchievementViewData(name: achievement.name, info: achievement.info ?? "", type: achievement.type, cover: achievement.cover ?? nil, isUnlocked: achievement.isUnlocked, currentProgress: achievement.progressValue, maxProgress: achievement.maxProgressValue))
        })
        
        view?.setAchievements(records: achievements)
        
        guard let stats = statsManager.stats else {
            view?.setGeneralStats(currentLevel: currentLevel, bestStreak: bestStreak, currentWeekXP: 0, last7DaysProgress: nil)
            view?.reload()
            return
        }
        
        let last7DaysProgress = statsManager.getLastDays(count: 7)
        var currentWeekXP = last7DaysProgress.reduce(0, +)
        
        view?.setGeneralStats(currentLevel: currentLevel, bestStreak: bestStreak, currentWeekXP: currentWeekXP, last7DaysProgress: last7DaysProgress)
        
        // Calculate progress by week
        func getWeekBeginByDate(_ date: Date) -> Date {
            let calendar = Calendar(identifier: .gregorian)
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        }

        // Empty stats
        if stats.first == nil {
            return
        }
        
        var weekXP: [Int: Int] = [:]
        var weeks: Set<Date> = Set<Date>()
        var weekRecordBeginHash: Int? = nil
        for (day, progress) in stats {
            let weekBeginForCurrentDay = getWeekBeginByDate(statsManager.dateByDay(day))
            let weekHash = weekBeginForCurrentDay.hashValue
            weeks.insert(weekBeginForCurrentDay)
            
            if weekXP[weekHash] == nil {
                if weekRecordBeginHash == nil {
                    weekRecordBeginHash = weekHash
                }
                weekXP[weekHash] = progress
            } else {
                weekXP[weekHash]! += progress
            }
            
            if weekXP[weekRecordBeginHash!]! < weekXP[weekHash]! {
                weekRecordBeginHash = weekHash
            }
        }
        
        for firstDayOfWeek in weeks {
            progressByWeek.append(WeekProgressViewData(weekBegin: firstDayOfWeek, progress: weekXP[firstDayOfWeek.hashValue] ?? 0, isRecord: firstDayOfWeek.hashValue == weekRecordBeginHash && weeks.count > 1))
        }
        
        view?.setProgress(records: progressByWeek.reversed())
        
        view?.reload()
    }
    
}
