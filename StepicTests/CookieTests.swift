//
//  CookieTests.swift
//  Stepic
//
//  Created by Alexander Karpov on 30.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest
@testable import Stepic

class CookieTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAnonymousAttempt() {
        let expectation = self.expectation(description: "testAnonymousAttempt")

        _ = Session.refresh(completion: {

                print("successfully refreshed session data")
                ApiDataDownloader.stepics.retrieveCurrentUser(success: {
                    user in
                        print("retrieved user \(user.id) \(user.firstName) \(user.lastName)")
                        ApiDataDownloader.attempts.create(stepName: "choice", stepId: 115260, success: {
                                attempt in
                                if let id = attempt.id {
                                    print("created attempt \(id)")
                                }
                                expectation.fulfill()
                            }, error: {
                                errorMsg in
                                XCTAssert(false, "error creating attempt: \(errorMsg)")
                            }
                        )
                    }, error: {
                        errorMsg in
                        XCTAssert(false, "error retrieving user: \(errorMsg)")
                    }
                )

            }, error: {
                _ in
                XCTAssert(false, "error refreshing session")
            }
        )

        waitForExpectations(timeout: 10.0) {
            error in
            if error != nil {
                XCTAssert(false, "Timeout error")
            }
        }

    }

}
