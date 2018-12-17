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
    override func spec() {
        describe("DeepLinkRoute") {
            context("catalog") {
                it("matches catalog deep link with last slash") {
                    let path = "https://stepik.org/catalog/"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case .catalog = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return .succeeded
                    }).to(succeed())
                }

                it("matches catalog deep link without last slash") {
                    let path = "https://stepik.org/catalog"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case .catalog = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return .succeeded
                    }).to(succeed())
                }
            }

            context("course") {
                it("matches course deep link with non empty query params") {
                    let path = "https://stepik.org/course/8092/?utm_source=newsletter&utm_medium=email&utm_campaign=monthly&utm_term=user-group4&utm_content=course"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .course(id) = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return id == 8092 ? .succeeded : .failed(reason: "wrong course id")
                    }).to(succeed())
                }

                it("matches course deep link with empty query params") {
                    let path = "https://stepik.org/course/8092/?"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .course(id) = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return id == 8092 ? .succeeded : .failed(reason: "wrong course id")
                    }).to(succeed())
                }

                it("matches course deep link without query params") {
                    let path = "https://stepik.org/course/8092"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .course(id) = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return id == 8092 ? .succeeded : .failed(reason: "wrong course id")
                    }).to(succeed())
                }
            }

            context("profile") {
                it("matches profile deep link with last slash") {
                    let path = "https://stepik.org/users/8092/"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .profile(id) = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return id == 8092 ? .succeeded : .failed(reason: "wrong course id")
                    }).to(succeed())
                }

                it("matches profile deep link without last slash") {
                    let path = "https://stepik.org/users/8092"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .profile(id) = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return id == 8092 ? .succeeded : .failed(reason: "wrong course id")
                    }).to(succeed())
                }
            }

            context("notifications") {
                it("matches notifications deep link with last slash") {
                    let path = "https://stepik.org/notifications/"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case .notifications = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return .succeeded
                    }).to(succeed())
                }

                it("matches notifications deep link without last slash") {
                    let path = "https://stepik.org/notifications"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case .notifications = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return .succeeded
                    }).to(succeed())
                }
            }

            context("syllabus") {
                it("matches syllabus deep link with query params") {
                    let path = "https://stepik.org/course/8092/syllabus/?utm_source=newsletter&utm_medium=email&utm_campaign=monthly&utm_term=user-group4&utm_content=course"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case .syllabus = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return .succeeded
                    }).to(succeed())
                }

                it("matches syllabus deep link with empty query params") {
                    let path = "https://stepik.org/course/8092/syllabus/?"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case .syllabus = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return .succeeded
                    }).to(succeed())
                }

                it("matches syllabus deep link with last slash") {
                    let path = "https://stepik.org/course/8092/syllabus/"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case .syllabus = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return .succeeded
                    }).to(succeed())
                }

                it("matches syllabus deep link without last slash") {
                    let path = "https://stepik.org/course/8092/syllabus"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case .syllabus = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        return .succeeded
                    }).to(succeed())
                }
            }

            context("lesson") {
                it("matches lesson deep link with unit id and without last slash") {
                    let path = "https://stepik.org/lesson/172508/step/1?unit=148015"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .lesson(lessonID, stepID, unitID) = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        guard lessonID == 172508 else {
                            return .failed(reason: "wrong lesson id")
                        }
                        guard stepID == 1 else {
                            return .failed(reason: "wrong step id")
                        }
                        guard unitID == 148015 else {
                            return .failed(reason: "wrong unit id")
                        }
                        return .succeeded
                    }).to(succeed())
                }

                it("matches lesson deep link with unit id and with last slash") {
                    let path = "https://stepik.org/lesson/172508/step/1?unit=148015/"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .lesson(lessonID, stepID, unitID) = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        guard lessonID == 172508 else {
                            return .failed(reason: "wrong lesson id")
                        }
                        guard stepID == 1 else {
                            return .failed(reason: "wrong step id")
                        }
                        guard unitID == 148015 else {
                            return .failed(reason: "wrong unit id")
                        }
                        return .succeeded
                    }).to(succeed())
                }

                it("matches lesson deep link without unit id and without last slash") {
                    let path = "https://stepik.org/lesson/172508/step/1"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .lesson(lessonID, stepID, unitID) = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        guard lessonID == 172508 else {
                            return .failed(reason: "wrong lesson id")
                        }
                        guard stepID == 1 else {
                            return .failed(reason: "wrong step id")
                        }
                        guard unitID == nil else {
                            return .failed(reason: "wrong unit id")
                        }
                        return .succeeded
                    }).to(succeed())
                }

                it("matches lesson deep link without unit id and with last slash") {
                    let path = "https://stepik.org/lesson/172508/step/1/"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .lesson(lessonID, stepID, unitID) = route! else {
                            return .failed(reason: "wrong enum case")
                        }
                        guard lessonID == 172508 else {
                            return .failed(reason: "wrong lesson id")
                        }
                        guard stepID == 1 else {
                            return .failed(reason: "wrong step id")
                        }
                        guard unitID == nil else {
                            return .failed(reason: "wrong unit id")
                        }
                        return .succeeded
                    }).to(succeed())
                }
            }

            context("discussions") {
                it("matches discussions deep link with unit id") {
                    let path = "https://stepik.org/lesson/172508/step/1?discussion=803115&unit=148015"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .discussions(lessonID, stepID, discussionID, unitID) = route! else {
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
                        guard unitID == 148015 else {
                            return .failed(reason: "wrong unit id")
                        }
                        return .succeeded
                    }).to(succeed())
                }

                it("matches discussions deep link with unit id and last slash") {
                    let path = "https://stepik.org/lesson/172508/step/1?discussion=803115&unit=148015/"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .discussions(lessonID, stepID, discussionID, unitID) = route! else {
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
                        guard unitID == 148015 else {
                            return .failed(reason: "wrong unit id")
                        }
                        return .succeeded
                    }).to(succeed())
                }

                it("matches discussions deep link without unit id") {
                    let path = "https://stepik.org/lesson/172508/step/1?discussion=803115"
                    let route = DeepLinkRoute(path: path)
                    expect({
                        guard case let .discussions(lessonID, stepID, discussionID, unitID) = route! else {
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
                        guard unitID == nil else {
                            return .failed(reason: "wrong unit id")
                        }
                        return .succeeded
                    }).to(succeed())
                }
            }
        }
    }
}
