//
//  TopicsPresenterTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 23/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
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
            model: KnowledgeGraph(),
            userRegistrationService: userRegistrationService,
            graphService: graphService
        )
    }

    func testViewDidLoadSuccessRefreshTopicsViewCalled() {
        let resultToBeReturned = KnowledgeGraphPlainObject.createGraph()
        graphService.resultToBeReturned = .success(resultToBeReturned)

        topicsPresenter.viewDidLoad()

        XCTAssertTrue(topicsViewSpy.refreshTopicsViewCalled, "refreshTopicsView was not called")
    }
}
