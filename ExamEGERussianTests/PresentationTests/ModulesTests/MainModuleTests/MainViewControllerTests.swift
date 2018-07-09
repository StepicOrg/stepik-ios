//
//  ExamEGERussianTests.swift
//  ExamEGERussianTests
//
//  Created by jetbrains on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class MainViewControllerTests: XCTestCase {

    func testMainScreen() {
        let vc = MainViewController()
        vc.userRegistrationService = ServiceComponentsAssemblyTestsHelper().serviceComponents.userRegistrationService

        XCTAssertNotNil(vc.view, "Could not instantiate MainViewController")
    }

}
