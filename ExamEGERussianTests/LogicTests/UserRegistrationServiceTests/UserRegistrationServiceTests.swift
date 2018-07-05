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
    
    var isAuthorized = false
    
    private let serviceComponents = ServiceComponentsAssembly(
        authAPI: AuthAPI(),
        stepicsAPI: StepicsAPI(),
        profilesAPI: ProfilesAPI(),
        defaultsStorageManager: DefaultsStorageManager()
    )
    
    func testUserRegistration() {
        serviceComponents.userRegistrationService.registerNewUser()
            .then { user -> Void in
                self.isAuthorized = true
            }
            .catch { error in
                self.isAuthorized = false
            }
        
        let predicate = NSPredicate(format: "isAuthorized == %@", NSNumber(value: true))
        let exp = expectation(for: predicate, evaluatedWith: self, handler: nil)
        let result = XCTWaiter.wait(for: [exp], timeout: 5.0)
        
        if result == XCTWaiter.Result.completed {
            XCTAssertTrue(isAuthorized, "User not authorized")
        } else {
            XCTAssert(false, "The call to register new user ran into some other error")
        }
    }
    
}
