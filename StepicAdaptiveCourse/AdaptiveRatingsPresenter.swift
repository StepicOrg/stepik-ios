//
//  AdaptiveRatingsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

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

    init(ratingsAPI: RatingsAPI, view: AdaptiveRatingsView) {
        self.view = view

        self.ratingsAPI = ratingsAPI
    }

    func reloadData(days: Int? = nil, force: Bool = false) {
        let downloadedScoreboard = scoreboard[days ?? 0] // 0 when 'days' == nil
        if downloadedScoreboard == nil || force {
            let currentUser = AuthInfo.shared.userId

            ratingsAPI.retrieve(courseId: StepicApplicationsInfo.adaptiveCourseId, count: 10, days: days, success: {
                ratings in
                var pos = 0
                var curScoreboard: [RatingViewData] = []
                ratings.forEach { record in
                    pos += 1
                    curScoreboard.append(RatingViewData(position: pos, exp: record.exp, name: "User \(record.userId)", me: currentUser == record.userId))
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
}
