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
        let router = MainViewRouterMock()
        vc.presenter = MainViewPresenterMock(router: router)
        XCTAssertNotNil(vc.view, "Could not instantiate MainViewController")
    }

}
