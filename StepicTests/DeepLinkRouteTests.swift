//
// DeepLinkRouteTests.swift
// stepik-ios
//
// Created by Ivan Magda on 2018-12-17.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble

@testable import Stepic

class DeepLinkRouteSpec: QuickSpec {
    private func makeRoute(for path: String) -> DeepLinkRoute {
        return DeepLinkRoute(path: path)!
    }

    private func checkPaths(_ paths: [String], result: @escaping (DeepLinkRoute) -> ToSucceedResult) {
        for path in paths {
            let route = self.makeRoute(for: path)
            expect({
                result(route)
            }).to(succeed())
        }
    }

    override func spec() {
        describe("DeepLinkRoute") {
            context("catalog") {
                it("matches catalog deep link with given paths") {
                    let paths = [
                        "https://stepik.org/catalog",
                        "https://stepik.org/catalog/"
                    ]
                    self.checkPaths(paths) { route in
                        guard case .catalog = route else {
                            return .failed(reason: "wrong enum case, expected `catalog`, got \(route)")
                        }
                        return .succeeded
                    }
                }
            }

            context("course") {
                it("matches course deep link with given paths") {
                    let paths = [
                        "https://stepik.org/course/8092",
                        "https://stepik.org/course/8092/",
                        "https://stepik.org/course/8092/?",
                        "https://stepik.org/course/8092/?utm_source=newsletter&utm_medium=email&utm_campaign=monthly&utm_term=user-group4&utm_content=course",
                        "https://stepik.org/course/8092/promo",
                        "https://stepik.org/course/8092/promo/",
                        "https://stepik.org/course/8092/promo/?",
                        "https://stepik.org/course/8092/promo/?utm_source=newsletter&utm_medium=email&utm_campaign=monthly&utm_term=user-group4&utm_content=course"
                    ]
                    self.checkPaths(paths) { route in
                        guard case let .course(id) = route else {
                            return .failed(reason: "wrong enum case, expected `course`, got \(route)")
                        }
                        return id == 8092 ? .succeeded : .failed(reason: "wrong course id")
                    }
                }
            }

            context("profile") {
                it("matches profile deep link with given paths") {
                    let paths = [
                        "https://stepik.org/users/8092",
                        "https://stepik.org/users/8092/"
                    ]
                    self.checkPaths(paths) { route in
                        guard case let .profile(id) = route else {
                            return .failed(reason: "wrong enum case, expected `profile`, got \(route)")
                        }
                        return id == 8092 ? .succeeded : .failed(reason: "wrong course id")
                    }
                }
            }

            context("notifications") {
                it("matches notifications deep link with given paths") {
                    let paths = [
                        "https://stepik.org/notifications",
                        "https://stepik.org/notifications/"
                    ]
                    self.checkPaths(paths) { route in
                        guard case .notifications = route else {
                            return .failed(reason: "wrong enum case, expected `notifications`, got \(route)")
                        }
                        return .succeeded
                    }
                }
            }

            context("syllabus") {
                it("matches syllabus deep link with given paths") {
                    let paths = [
                        "https://stepik.org/course/8092/syllabus",
                        "https://stepik.org/course/8092/syllabus/",
                        "https://stepik.org/course/8092/syllabus/?",
                        "https://stepik.org/course/8092/syllabus/?utm_source=newsletter&utm_medium=email&utm_campaign=monthly&utm_term=user-group4&utm_content=course"
                    ]
                    self.checkPaths(paths) { route in
                        guard case .syllabus = route else {
                            return .failed(reason: "wrong enum case, expected `syllabus`, got \(route)")
                        }
                        return .succeeded
                    }
                }
            }

            context("lesson") {
                func checkRoute(_ route: DeepLinkRoute, expectedUnitID: Int?) -> ToSucceedResult {
                    guard case let .lesson(lessonID, stepID, unitID) = route else {
                        return .failed(reason: "wrong enum case, expected `lesson`, got \(route)")
                    }
                    guard lessonID == 172508 else {
                        return .failed(reason: "wrong lesson id")
                    }
                    guard stepID == 1 else {
                        return .failed(reason: "wrong step id")
                    }
                    guard unitID == expectedUnitID else {
                        return .failed(reason: "wrong unit id")
                    }
                    return .succeeded
                }

                it("matches lesson deep link paths with unit id") {
                    let paths = [
                        "https://stepik.org/lesson/172508/step/1?unit=148015",
                        "https://stepik.org/lesson/172508/step/1?unit=148015/"
                    ]
                    self.checkPaths(paths) { route in
                        checkRoute(route, expectedUnitID: 148015)
                    }
                }

                it("matches lesson deep link paths without unit id") {
                    let paths = [
                        "https://stepik.org/lesson/172508/step/1",
                        "https://stepik.org/lesson/172508/step/1/"
                    ]
                    self.checkPaths(paths) { route in
                        checkRoute(route, expectedUnitID: nil)
                    }
                }
            }

            context("discussions") {
                func checkRoute(_ route: DeepLinkRoute, expectedUnitID: Int?) -> ToSucceedResult {
                    guard case let .discussions(lessonID, stepID, discussionID, unitID) = route else {
                        return .failed(reason: "wrong enum case")
                    }
                    guard lessonID == 172508 else {
                        return .failed(reason: "wrong lesson id")
                    }
                    guard stepID == 1 else {
                        return .failed(reason: "wrong step id")
                    }
                    guard discussionID == 803115 else {
                        return .failed(reason: "wrong discussion id")
                    }
                    guard unitID == expectedUnitID else {
                        return .failed(reason: "wrong unit id")
                    }
                    return .succeeded
                }

                it("matches discussions deep link paths with unit id") {
                    let paths = [
                        "https://stepik.org/lesson/172508/step/1?discussion=803115&unit=148015",
                        "https://stepik.org/lesson/172508/step/1?discussion=803115&unit=148015/"
                    ]
                    self.checkPaths(paths) { route in
                        checkRoute(route, expectedUnitID: 148015)
                    }
                }

                it("matches discussions deep link without unit id") {
                    let paths = [
                        "https://stepik.org/lesson/172508/step/1?discussion=803115"
                    ]
                    self.checkPaths(paths) { route in
                        checkRoute(route, expectedUnitID: nil)
                    }
                }
            }
        }
    }
}
