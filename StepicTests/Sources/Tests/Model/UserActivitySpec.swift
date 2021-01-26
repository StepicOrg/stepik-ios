//
//  UserActivitySpec.swift
//  StepicTests
//
//  Created by Vladislav Kiryukhin on 07.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

import Quick
import Nimble
import SwiftyJSON

@testable import Stepic

class UserActivitySpec: QuickSpec {
    override func spec() {
        describe("UserActivity") {
            context("when constructed with id") {
                let ua = UserActivity(id: 239)
                it("has id and empty year-pins") {
                    expect(ua.id) == 239
                    expect(ua.pins) == (1...365).map { _ in 0 }
                }
            }

            context("when constructed with json") {
                let sampleObj = ["id": 239, "pins": (1...7).map({ $0 })] as [String : Any]
                let ua = UserActivity(json: JSON(sampleObj))
                it("has correct id and pins") {
                    expect(ua.id) == 239
                    expect(ua.pins) == (1...7).map({ $0 })
                }
            }

            context("when constructed with empty pins list") {
                let sampleObj = ["id": 239, "pins": []] as [String : Any]
                let ua = UserActivity(json: JSON(sampleObj))
                it("has correct properties") {
                    expect(ua.pins) == []
                    expect(ua.currentStreak) == 0
                    expect(ua.longestStreak) == 0
                    expect(ua.didSolveThisWeek) == false
                    expect(ua.needsToSolveToday) == false
                }
            }

            context("empty year generator") {
                it("365 pins and all are 0") {
                    let pins = UserActivity.emptyYearPins
                    expect(pins.count) == 365
                    expect(pins.filter({ $0 == 0 }).count) == 365
                }
            }

            context("when constructed with data") {
                it("has currentStreak == 0") {
                    let sampleObj = ["id": 239, "pins": [0, 0, 2, 0, 1, 0]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.currentStreak) == 0
                }

                it("has currentStreak == 3") {
                    let sampleObj = ["id": 239, "pins": [0, 1, 2, 1, 0, 4, 2]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.currentStreak) == 3
                }

                it("has longestStreak == 0") {
                    let sampleObj = ["id": 239, "pins": [0, 0, 0]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.longestStreak) == 0
                }

                it("has longestStreak == 1") {
                    let sampleObj = ["id": 239, "pins": [0, 1, 0, 1, 0]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.longestStreak) == 1
                }

                it("has longestStreak == 3") {
                    let sampleObj = ["id": 239, "pins": [1, 0, 2, 3, 4, 0, 1, 1, 0, 0, 1, 1, 0, 1]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.longestStreak) == 3
                }

                it("didn't solve this week") {
                    let sampleObj = ["id": 239, "pins": [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 2]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.didSolveThisWeek) == false
                }

                it("did solve this week") {
                    let sampleObj = ["id": 239, "pins": [0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 2]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.didSolveThisWeek) == true
                }

                it("did solve today") {
                    let sampleObj = ["id": 239, "pins": [1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 2]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.didSolveToday) == true
                }

                it("didn't solve today") {
                    let sampleObj = ["id": 239, "pins": [0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 2]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.didSolveToday) == false
                }

                it("needs to solve today") {
                    let sampleObj = ["id": 239, "pins": [0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 2]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.needsToSolveToday) == true
                }

                it("dont need to solve today, today pin > 0") {
                    let sampleObj = ["id": 239, "pins": [6, 0, 0, 0, 0, 0, 1, 1, 0, 1, 2]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.needsToSolveToday) == false
                }

                it("dont need to solve today, has no solved yesterday") {
                    let sampleObj = ["id": 239, "pins": [0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 2]] as [String : Any]
                    let ua = UserActivity(json: JSON(sampleObj))

                    expect(ua.needsToSolveToday) == false
                }
            }
        }
    }
}
