//
//  AdaptiveRatingsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

protocol AdaptiveRatingsView: AnyObject {
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

final class AdaptiveRatingsPresenter {
    weak var view: AdaptiveRatingsView?

    private let ratingsAPI: AdaptiveRatingsAPI
    private let usersAPI: UsersAPI
    private let ratingManager: AdaptiveRatingManager
    private let analytics: Analytics

    private var scoreboard: [Int: ScoreboardViewData] = [:]

    // Names (word + grammatical gender)
    private var nouns: [(String, String)] = []
    private var adjs: [(String, String)] = []

    init(
        ratingsAPI: AdaptiveRatingsAPI,
        usersAPI: UsersAPI,
        ratingManager: AdaptiveRatingManager,
        analytics: Analytics = StepikAnalytics.shared,
        view: AdaptiveRatingsView
    ) {
        self.view = view
        self.ratingManager = ratingManager
        self.ratingsAPI = ratingsAPI
        self.usersAPI = usersAPI
        self.analytics = analytics

        self.loadNamesFromFiles()
    }

    func reloadData(days: Int? = nil, force: Bool = false) {
        // Send rating first, then get rating
        ratingsAPI.cancelAllTasks()
        ratingsAPI.update(courseId: ratingManager.courseID, exp: ratingManager.rating).then { _ -> Promise<ScoreboardViewData> in
            print("adaptive ratings: remote rating updated -> reload rating")
            let downloadedScoreboard = self.scoreboard[days ?? 0] // 0 when 'days' == nil
            if downloadedScoreboard == nil || force {
                return self.reloadRating(days: days)
            } else {
                return .value(downloadedScoreboard!)
            }
        }.done { scoreboard in
            self.scoreboard[days ?? 0] = scoreboard
            self.view?.setRatings(data: scoreboard)
            self.view?.reload()
        }.catch { error in
            switch error {
            case RatingsAPIError.serverError:
                print("adaptive ratings: remote rating update failed: server error")
                self.analytics.send(.errorAdaptiveRatingServer)
            default:
                print("adaptive ratings: remote rating update failed: \(error)")
            }
            self.view?.showError()
        }
    }

    func sendOpenedAnalytics() {
        self.analytics.send(.adaptiveRatingOpened(courseID: self.ratingManager.courseID))
    }

    private func reloadRating(days: Int? = nil) -> Promise<ScoreboardViewData> {
        Promise { seal in
            let currentUser = AuthInfo.shared.userId
            var usersForDeanonIds = [Int]()
            var loadedScoreboard: AdaptiveRatingsAPI.Scoreboard?

            ratingsAPI.cancelAllTasks()
            ratingsAPI.retrieve(courseId: ratingManager.courseID, count: 10, days: days).then { scoreboard -> Guarantee<[User]> in
                loadedScoreboard = scoreboard
                usersForDeanonIds = scoreboard.leaders.filter({ !$0.isFake }).map { $0.userId }

                return User.fetchAsync(ids: usersForDeanonIds)
            }.then { cachedUsers -> Promise<[User]> in
                self.usersAPI.retrieve(ids: usersForDeanonIds, existing: cachedUsers)
            }.recover { _ -> Promise<[User]> in
                // Unable to fetch users -> recover with empty array
                return .value([])
            }.done { users in
                var userNames: [Int: String] = [:]
                let locale = String(Locale.preferredLanguages.first?.split(separator: "-").first ?? "en")
                users.forEach { user in
                    if ["ru", "ua"].contains(locale) {
                        userNames[user.id] = user.fullName
                    } else {
                        userNames[user.id] = StringHelper.cyrillicToLatin(user.fullName)
                    }
                }

                var curLeaders: [RatingViewData] = []
                loadedScoreboard?.leaders.forEach { record in
                    let name = userNames[record.userId] ?? self.generateNameBy(userId: record.userId)
                    curLeaders.append(RatingViewData(position: record.rank, exp: record.exp, name: name, me: currentUser == record.userId))
                }

                let curScoreboard = ScoreboardViewData(allCount: loadedScoreboard?.allCount ?? 0, leaders: curLeaders)
                seal.fulfill(curScoreboard)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func loadNamesFromFiles() {
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

    private func generateNameBy(userId: Int) -> String {
        func hash(_ id: Int) -> Int {
            var x = id
            x = ((x >> 16) ^ x) &* 0x45d9f3b
            x = ((x >> 16) ^ x) &* 0x45d9f3b
            x = (x >> 16) ^ x
            return x % (nouns.count * (adjs.count / 2))
        }

        let noun = nouns[hash(userId) % nouns.count]
        let adjsByGender = adjs.compactMap { noun.1 == $0.1 ? $0 : nil }
        let adjNum = hash(userId) / nouns.count

        return "\(adjsByGender[adjNum].0.capitalized) \(noun.0)"
    }
}
