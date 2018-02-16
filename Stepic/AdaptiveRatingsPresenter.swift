//
//  AdaptiveRatingsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

protocol AdaptiveRatingsView: class {
    func reload()
    func setRatings(data: ScoreboardViewData)
    func showError()
}

struct RatingViewData {
    let position: Int
    let exp: Int
    let name: String
    let me: Bool
}

struct ScoreboardViewData {
    let allCount: Int
    let leaders: [RatingViewData]
}

class AdaptiveRatingsPresenter {
    weak var view: AdaptiveRatingsView?

    fileprivate var ratingsAPI: AdaptiveRatingsAPI
    fileprivate var ratingManager: AdaptiveRatingManager

    private var scoreboard: [Int: ScoreboardViewData] = [:]

    // Names (word + grammatical gender)
    private var nouns: [(String, String)] = []
    private var adjs: [(String, String)] = []

    init(ratingsAPI: AdaptiveRatingsAPI, ratingManager: AdaptiveRatingManager, view: AdaptiveRatingsView) {
        self.view = view
        self.ratingManager = ratingManager
        self.ratingsAPI = ratingsAPI

        loadNamesFromFiles()
    }

    func reloadData(days: Int? = nil, force: Bool = false) {
        // Send rating first, then get rating
        ratingsAPI.cancelAllTasks()
        ratingsAPI.update(courseId: ratingManager.courseId, exp: ratingManager.rating).then { _ -> Promise<ScoreboardViewData> in
            print("adaptive ratings: remote rating updated -> reload rating")
            let downloadedScoreboard = self.scoreboard[days ?? 0] // 0 when 'days' == nil
            if downloadedScoreboard == nil || force {
                return self.reloadRating(days: days, force: force)
            } else {
                return Promise(value: downloadedScoreboard!)
            }
        }.then { scoreboard -> Void in
            self.scoreboard[days ?? 0] = scoreboard
            self.view?.setRatings(data: scoreboard)
            self.view?.reload()
        }.catch { error in
            switch error {
            case RatingsAPIError.serverError:
                print("adaptive ratings: remote rating update failed: server error")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.adaptiveRatingServer)
            default:
                print("adaptive ratings: remote rating update failed: \(error)")
            }
            self.view?.showError()
        }
    }

    fileprivate func reloadRating(days: Int? = nil, force: Bool = false) -> Promise<ScoreboardViewData> {
        return Promise { fulfill, reject in
            let currentUser = AuthInfo.shared.userId

            ratingsAPI.cancelAllTasks()
            ratingsAPI.retrieve(courseId: ratingManager.courseId, count: 10, days: days).then { scoreboard -> Void in
                var curLeaders: [RatingViewData] = []
                scoreboard.leaders.forEach { record in
                    curLeaders.append(RatingViewData(position: record.rank, exp: record.exp, name: self.generateNameBy(userId: record.userId), me: currentUser == record.userId))
                }

                let curScoreboard = ScoreboardViewData(allCount: scoreboard.allCount, leaders: curLeaders)
                fulfill(curScoreboard)
            }.catch { error in
                reject(error)
            }
        }
    }

    fileprivate func loadNamesFromFiles() {
        func readFile(name: String) -> [String] {
            if let path = Bundle.main.path(forResource: name, ofType: "plist"),
                let words = NSArray(contentsOfFile: path) as? [String] {
                return words
            }
            return []
        }

        readFile(name: "adjectives_m").forEach { adjs.append(($0, "m")) }
        readFile(name: "adjectives_f").forEach { adjs.append(($0, "f")) }
        readFile(name: "nouns_m").forEach { nouns.append(($0, "m")) }
        readFile(name: "nouns_f").forEach { nouns.append(($0, "f")) }

        assert(adjs.count % 2 == 0)
    }

    fileprivate func generateNameBy(userId: Int) -> String {
        func hash(_ id: Int) -> Int {
            var x = id
            x = ((x >> 16) ^ x) &* 0x45d9f3b
            x = ((x >> 16) ^ x) &* 0x45d9f3b
            x = (x >> 16) ^ x
            return x % (nouns.count * (adjs.count / 2))
        }

        let noun = nouns[hash(userId) % nouns.count]
        let adjsByGender = adjs.flatMap { noun.1 == $0.1 ? $0 : nil }
        let adjNum = hash(userId) / nouns.count

        return "\(adjsByGender[adjNum].0.capitalized) \(noun.0)"
    }
}
