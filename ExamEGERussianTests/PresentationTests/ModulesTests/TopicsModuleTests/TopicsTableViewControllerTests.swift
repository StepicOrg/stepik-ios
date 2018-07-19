//
//  ExamEGERussianTests.swift
//  ExamEGERussianTests
//
//  Created by jetbrains on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class TopicsTableViewControllerTests: XCTestCase {

    func testMainScreen() {
        let vc = TopicsTableViewController()
        let presenter = TopicsPresenterImpl(
            view: vc,
            userRegistrationService: UserRegistrationServiceMock(),
            graphService: GraphServiceMock()
        )
        vc.presenter = presenter

        XCTAssertNotNil(vc.view, "Could not instantiate MainViewController")
    }

}
