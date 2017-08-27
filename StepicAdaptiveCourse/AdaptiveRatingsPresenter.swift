//
//  AdaptiveRatingsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire

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

    fileprivate var ratingsAPI: RatingsAPI
    fileprivate var ratingManager: RatingManager

    private var scoreboard: [Int: ScoreboardViewData] = [:]

    private var currentRequest: Request?

    // Names (word + grammatical gender)
    private var nouns: [(String, String)] = []
    private var adjs: [(String, String)] = []

    init(ratingsAPI: RatingsAPI, ratingManager: RatingManager, view: AdaptiveRatingsView) {
        self.view = view
        self.ratingManager = ratingManager
        self.ratingsAPI = ratingsAPI

        loadNamesFromFiles()
    }

    func reloadData(days: Int? = nil, force: Bool = false) {
        // Send rating first, then get rating
        currentRequest?.cancel()
        currentRequest = ratingsAPI.update(courseId: StepicApplicationsInfo.adaptiveCourseId, exp: ratingManager.rating, success: { _ in
            print("remote rating updated -> reload rating")
            self.reloadRating(days: days, force: force)
        }, error: { responseStatus in
            switch responseStatus {
            case .serverError:
                print("remote rating update failed: server error")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.ratingServerError)
            case .connectionError(let error):
                print("remote rating update failed: \(error)")
            default:
                print("remote rating update failed: \(responseStatus)")
            }
            self.view?.showError()
        })
    }

    fileprivate func reloadRating(days: Int? = nil, force: Bool = false) {
        let downloadedScoreboard = scoreboard[days ?? 0] // 0 when 'days' == nil
        if downloadedScoreboard == nil || force {
            let currentUser = AuthInfo.shared.userId

            currentRequest?.cancel()
            currentRequest = ratingsAPI.retrieve(courseId: StepicApplicationsInfo.adaptiveCourseId, count: 10, days: days, success: { scoreboard in
                var curLeaders: [RatingViewData] = []
                scoreboard.leaders.forEach { record in
                    curLeaders.append(RatingViewData(position: record.rank, exp: record.exp, name: self.generateNameBy(userId: record.userId), me: currentUser == record.userId))
                }

                let curScoreboard = ScoreboardViewData(allCount: scoreboard.allCount, leaders: curLeaders)
                self.scoreboard[days ?? 0] = curScoreboard
                self.view?.setRatings(data: curScoreboard)
                self.view?.reload()
            }, error: { err in
                print(err)
                self.view?.showError()
            })
        } else {
            view?.setRatings(data: downloadedScoreboard!)
            view?.reload()
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
