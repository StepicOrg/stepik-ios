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

    func testViewDidLoadFailureDisplayError() {
        let expectedErrorTitle = "Error"
        let expectedErrorMessage = "Some error message"
        let errorToBeReturned = NSError.createError(withMessage: expectedErrorMessage)
        graphService.resultToBeReturned = .failure(errorToBeReturned)

        topicsPresenter.viewDidLoad()

        XCTAssertEqual(expectedErrorTitle, topicsViewSpy.displayErrorTitle, "Error title doesn't match")
        XCTAssertEqual(expectedErrorMessage, topicsViewSpy.displayErrorMessage, "Error message doesn't match")
    }

    func testConfigureCell() {
        let resultToBeReturned = KnowledgeGraphPlainObject.createGraph()
        graphService.resultToBeReturned = .success(resultToBeReturned)

        topicsPresenter.viewDidLoad()

        let expectedDisplayedTitle = "B13 Слитное раздельное написание"
        let topicCellView = TopicCellViewSpy()

        topicsPresenter.configure(cell: topicCellView, forRow: 1)

        XCTAssertEqual(expectedDisplayedTitle, topicCellView.displayedTitle, "The title we expected was not displayed")
    }
}
