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

    override func setUp() {
        super.setUp()

        recommendationsAPIMock = RecommendationsAPIMock()
        recommendationsService = RecommendationsService(recommendationsAPI: recommendationsAPIMock)
    }

    override func tearDown() {
        super.tearDown()

        recommendationsAPIMock = nil
        recommendationsService = nil
    }

    func testRecommendationsServiceSuccessfulResponse() {
        let ex = expectation(description: "\(#function)")

        let result = [1, 2, 3]
        recommendationsAPIMock.resultToBeReturned = .value(result)
        recommendationsService.fetchForCourseWithId(1).done { lessonsIds in
            XCTAssertTrue(result == lessonsIds)
            ex.fulfill()
        }.catch { _ in
            XCTFail("Lessons ids should be returned")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRecommendationsServiceFailResponse() {
        let ex = expectation(description: "\(#function)")

        recommendationsService.fetchForCourseWithId(1).done { _ in
            XCTFail("Error should be returned")
            ex.fulfill()
        }.catch { error in
            XCTAssertTrue(error.localizedDescription == NSError.mockError.localizedDescription)
            ex.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
