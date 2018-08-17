//
//  ReactionServiceTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 17/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
import PromiseKit
@testable import ExamEGERussian

class ReactionServiceTests: XCTestCase {
    var reactionService: ReactionService!
    var reactionsAPIMock: ReactionsAPIMock!

    override func setUp() {
        super.setUp()

        reactionsAPIMock = ReactionsAPIMock()
        reactionService = ReactionService(recommendationsAPI: reactionsAPIMock)
    }

    override func tearDown() {
        super.tearDown()

        reactionsAPIMock = nil
        reactionService = nil
    }

    func testReactionServiceSuccessfullReactionResponse() {
        let ex = expectation(description: "\(#function)")

        reactionsAPIMock.resultToBeReturned = .value(())
        reactionService.sendReaction(.solved, forLesson: 1, byUser: 1).done {
            ex.fulfill()
        }.catch { _ in
            XCTFail("Shouldn't happen")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testReactionServiceFailableReactionResponse() {
        let ex = expectation(description: "\(#function)")

        let errorMessage = "ReactionsAPIMock error"
        reactionsAPIMock.resultToBeReturned = Promise(error: NSError.make(with: errorMessage))

        reactionService.sendReaction(.interesting, forLesson: 1, byUser: 1).done {
            XCTFail("Error should be returned")
            ex.fulfill()
        }.catch { error in
            XCTAssertTrue(error.localizedDescription == errorMessage)
            ex.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
