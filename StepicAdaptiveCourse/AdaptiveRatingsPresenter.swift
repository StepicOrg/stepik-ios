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
    func setRatings(records: [RatingViewData])
}

struct RatingViewData {
    let position: Int
    let exp: Int
    let name: String
    let me: Bool
}

class AdaptiveRatingsPresenter {
    weak var view: AdaptiveRatingsView?

    fileprivate var ratingsAPI: RatingsAPI

    private var scoreboard: [Int: [RatingViewData]] = [:]
    
    private var currentRequest: Request?

    // Names (word + grammatical gender)
    private var nouns: [(String, String)] = []
    private var adjs: [(String, String)] = []

    init(ratingsAPI: RatingsAPI, view: AdaptiveRatingsView) {
        self.view = view

        self.ratingsAPI = ratingsAPI

        loadNamesFromFiles()
    }

    func reloadData(days: Int? = nil, force: Bool = false) {
        let downloadedScoreboard = scoreboard[days ?? 0] // 0 when 'days' == nil
        if downloadedScoreboard == nil || force {
            let currentUser = AuthInfo.shared.userId

            currentRequest?.cancel()
            currentRequest = ratingsAPI.retrieve(courseId: StepicApplicationsInfo.adaptiveCourseId, count: 10, days: days, success: {
                ratings in
                var curScoreboard: [RatingViewData] = []
                ratings.forEach { record in
                    curScoreboard.append(RatingViewData(position: record.rank, exp: record.exp, name: self.generateNameBy(userId: record.userId), me: currentUser == record.userId))
                }

                self.scoreboard[days ?? 0] = curScoreboard
                self.view?.setRatings(records: curScoreboard)
                self.view?.reload()
            }, error: { err in
                print(err)
                self.view?.setRatings(records: [])
                self.view?.reload()
            })
        } else {
            view?.setRatings(records: downloadedScoreboard!)
            view?.reload()
        }
    }

    fileprivate func loadNamesFromFiles() {
        func readTxtFile(name: String) -> [String] {
            var result: [String] = []
            do {
                if let path = Bundle.main.path(forResource: name, ofType: "txt") {
                    let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                    result = data.components(separatedBy: ", ")
                }
            } catch let err as NSError {
                print("error while reading file \(name).txt: \(err)")
            }
            return result
        }

        readTxtFile(name: "adjectives_m").forEach { adjs.append(($0.trimmingCharacters(in: .whitespacesAndNewlines), "m")) }
        readTxtFile(name: "adjectives_f").forEach { adjs.append(($0.trimmingCharacters(in: .whitespacesAndNewlines), "f")) }
        readTxtFile(name: "nouns_m").forEach { nouns.append(($0.trimmingCharacters(in: .whitespacesAndNewlines), "m")) }
        readTxtFile(name: "nouns_f").forEach { nouns.append(($0.trimmingCharacters(in: .whitespacesAndNewlines), "f")) }

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
