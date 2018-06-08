//
//  ProfileAchievementsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProfileAchievementsView: class {

}

class ProfileAchievementsPresenter {
    weak var view: ProfileAchievementsView?

    init(view: ProfileAchievementsView) {
        self.view = view

        loadAchievementProgresses()
    }

    var achievementsAPI = AchievementsAPI()
    var achievementProgressesAPI = AchievementProgressesAPI()

    func loadAchievementProgresses() {
        var uniqueKinds: Set<String> = Set()
        achievementProgressesAPI.retrieve(user: AuthInfo.shared.userId ?? 1, order: .desc(param: "obtain_date")).then { (progresses, _) -> Void in
            var noObtained = false
            for p in progresses {
                if p.obtainDate != nil {
                    if !uniqueKinds.contains(p.kind) {
                        uniqueKinds.insert(p.kind)
                    }

                    if uniqueKinds.count == 4 {
                        break
                    }
                } else {
                    noObtained = true
                    break
                }
            }

            if uniqueKinds.count < 4 && !noObtained {
                // should recursive load on the next page
            } else {
                print(uniqueKinds)
            }

            for x in Array(uniqueKinds) {
                self.loadAchievements(kind: x).then { data in
                    print(data)
                }.catch { error in
                    print(error)
                }
            }
        }.catch { error in
            print(error)
        }
    }
}