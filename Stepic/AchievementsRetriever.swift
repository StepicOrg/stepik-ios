//
//  AchievementsRetriever.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 08.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//
import PromiseKit
import Foundation

class AchievementsRetriever {
    private var userId: Int

    private var achievementsAPI: AchievementsAPI
    private var achievementProgressesAPI: AchievementProgressesAPI

    init(userId: Int, achievementsAPI: AchievementsAPI, achievementProgressesAPI: AchievementProgressesAPI) {
        self.userId = userId
        self.achievementsAPI = achievementsAPI
        self.achievementProgressesAPI = achievementProgressesAPI
    }

    func loadAchievementProgress(for achievement: Achievement) -> Promise<AchievementProgressData> {
        return loadAchievementProgress(for: achievement.kind)
    }

    func loadAchievementProgress(for kind: String) -> Promise<AchievementProgressData> {
        return Promise { fulfill, reject in
            let allAchievementsWithKind: Promise<[Achievement]> = Promise { fulfill, reject in
                achievementsAPI.retrieve(kind: kind).then { achievements, _ -> Void in
                    fulfill(achievements)
                }.catch { error in
                    reject(error)
                }
            }
            let allProgressesWithKind: Promise<[AchievementProgress]> = Promise { fulfill, reject in
                achievementProgressesAPI.retrieve(user: userId, kind: kind).then { progresses, _ -> Void in
                    fulfill(progresses)
                }.catch { error in
                    reject(error)
                }
            }

            when(fulfilled: allAchievementsWithKind, allProgressesWithKind).then { (achievements, progresses) -> Void in
                // achievement id -> target score
                var idToTargetScore = [Int: Int]()
                for achievement in achievements.sorted(by: { $0.targetScore < $1.targetScore }) {
                    idToTargetScore[achievement.id] = achievement.targetScore
                }

                var levelCount = 0
                let progressesSortedByMaxScore = progresses.sorted(by: { a, b in
                    let lhs = idToTargetScore[a.achievement] ?? 0
                    let rhs = idToTargetScore[b.achievement] ?? 0
                    return lhs < rhs
                })
                for progress in progressesSortedByMaxScore {
                    if progress.obtainDate == nil {
                        fulfill(AchievementProgressData(currentScore: progress.score,
                                                        maxScore: idToTargetScore[progress.achievement] ?? 0,
                                                        currentLevel: levelCount,
                                                        maxLevel: achievements.count,
                                                        kind: kind))
                        return
                    }
                    levelCount += 1
                }

                if let lastProgress = progressesSortedByMaxScore.last {
                    // Fulfilled achievement
                    fulfill(AchievementProgressData(currentScore: lastProgress.score,
                        maxScore: lastProgress.score,
                        currentLevel: achievements.count,
                        maxLevel: achievements.count,
                        kind: kind))
                } else {
                    // Empty achievement
                    fulfill(AchievementProgressData(currentScore: 0,
                        maxScore: 0,
                        currentLevel: 0,
                        maxLevel: achievements.count,
                        kind: kind))
                }
            }.catch { error in
                reject(error)
            }
        }
    }
}

struct AchievementProgressData {
    var currentScore: Int
    var maxScore: Int
    var currentLevel: Int
    var maxLevel: Int
    var kind: String
}
