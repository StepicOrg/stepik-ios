//
//  AchievementsRetriever.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 08.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class AchievementsRetriever {
    private var userId: Int

    private var achievementsAPI: AchievementsAPI
    private var achievementProgressesAPI: AchievementProgressesAPI

    init(userId: Int, achievementsAPI: AchievementsAPI, achievementProgressesAPI: AchievementProgressesAPI) {
        self.userId = userId
    }

    func loadAchievementProgress(for achievement: Achievement) -> Promise<AchievementProgressData> {
        return loadBadgeInfo(for: achievement.kind)
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
                                                        maxLevel: achievements.count))
                        return
                    }
                    levelCount += 1
                }
                fulfill(AchievementProgressData(currentScore: progressesSortedByMaxScore.last?.score ?? 0,
                                                maxScore: progressesSortedByMaxScore.last?.score ?? 0,
                                                currentLevel: achievements.count,
                                                maxLevel: achievements.count))
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
}
