//
//  RecommendationsServiceTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 17/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
import PromiseKit
@testable import ExamEGERussian

class RecommendationsServiceTests: XCTestCase {
    var recommendationsService: RecommendationsService!
    var recommendationsAPIMock: RecommendationsAPIMock!
    var lessonsServiceMock: LessonsServiceMock!

    override func setUp() {
        super.setUp()

        lessonsServiceMock = LessonsServiceMock()
        recommendationsAPIMock = RecommendationsAPIMock()
        recommendationsService = RecommendationsService(
            recommendationsAPI: recommendationsAPIMock,
            lessonsService: lessonsServiceMock
        )
    }

    override func tearDown() {
        super.tearDown()

        lessonsServiceMock = nil
        recommendationsAPIMock = nil
        recommendationsService = nil
    }

    func testRecommendationsServiceLessonsIdsSuccessfulResponse() {
        let ex = expectation(description: "\(#function)")

        let expectedResult = [1, 2, 3]
        recommendationsAPIMock.resultToBeReturned = .value(expectedResult)
        recommendationsService.fetchIdsForCourseWithId(1).done { lessonsIds in
            XCTAssertTrue(expectedResult == lessonsIds)
            ex.fulfill()
        }.catch { _ in
            XCTFail("Lessons ids should be returned")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRecommendationsServiceFailResponse() {
        let ex = expectation(description: "\(#function)")

        let errorMessage = "RecommendationsAPIMock error"
        recommendationsAPIMock.resultToBeReturned = Promise(error: NSError.make(with: errorMessage))

        recommendationsService.fetchIdsForCourseWithId(1).done { _ in
            XCTFail("Error should be returned")
            ex.fulfill()
        }.catch { error in
            XCTAssertTrue(error.localizedDescription == errorMessage)
            ex.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRecommendationsServiceLessonsPlainObjectsSuccessfulResponse() {
        let ex = expectation(description: "\(#function)")

        let expectedResult = LessonPlainObject.make()
        recommendationsAPIMock.resultToBeReturned = .value([])
        lessonsServiceMock.resultToBeReturned = .value([expectedResult])

        recommendationsService.fetchLessonsForCourseWithId(1).done { lessons in
            XCTAssertTrue(lessons.count == 1)
            XCTAssertTrue(expectedResult == lessons.first!)
            ex.fulfill()
        }.catch { _ in
            XCTFail("Lessons ids should be returned")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
