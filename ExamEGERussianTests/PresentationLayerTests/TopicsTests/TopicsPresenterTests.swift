//
//  TopicsPresenterTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 23/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
import PromiseKit
@testable import ExamEGERussian

class TopicsPresenterTests: XCTestCase {
    let userRegistrationService = UserRegistrationServiceMock()
    let graphService = GraphServiceMock()
    let topicsViewSpy = TopicsViewSpy()
    var topicsPresenter: TopicsPresenterImpl!

    override func setUp() {
        super.setUp()

        topicsPresenter = TopicsPresenterImpl(
            view: topicsViewSpy,
            knowledgeGraph: KnowledgeGraph(),
            router: TopicsRouterMock(),
            userRegistrationService: userRegistrationService,
            graphService: graphService
        )
    }

    func testSuccessResponseEqualCountTopics() {
        let exp = expectation(description: "Equal count of fetched and mapped topics")

        let resultToBeReturned = KnowledgeGraphPlainObject.make()
        graphService.resultToBeReturned = .value(resultToBeReturned)
        topicsViewSpy.onSet = {
            XCTAssertTrue(self.topicsViewSpy.topics!.count == resultToBeReturned.topics.count, "not equal count of topics")
            exp.fulfill()
        }

        topicsPresenter.refresh()

        wait(for: [exp], timeout: 1.0)
    }
}
