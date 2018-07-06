//
//  UserRegistrationServiceTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 05/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
import PromiseKit
@testable import ExamEGERussian

class UserRegistrationServiceTests: XCTestCase {
    
    var service: UserRegistrationServiceMock!
    
    override func setUp() {
        super.setUp()
        service = UserRegistrationServiceMock()
    }
    
    override func tearDown() {
        super.tearDown()
        service = nil
    }
    
    func testSuccessfulResponse() {
        let ex = expectation(description: "\(#function)")
        
        service.user = User()
        service.registerNewUser().done { _ in
            XCTAssert(true)
            ex.fulfill()
        }.catch { _ in
            XCTFail()
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFailResponse() {
        let ex = expectation(description: "\(#function)")
        
        service.error = UserRegistrationServiceError.notRegistered
        service.registerNewUser().done { _ in
            XCTFail()
            ex.fulfill()
        }.catch { _ in
            XCTAssert(true)
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
