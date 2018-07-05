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
        let sb = UIStoryboard(name: "Main", bundle: nil)
        XCTAssertNotNil(sb, "Could not instantiate storyboard for main view creation")
        
        let identifier = String(describing: MainViewController.self)
        let vc = sb.instantiateViewController(withIdentifier: identifier) as? MainViewController
        vc?.userRegistrationService = ServiceComponentsAssemblyTestsHelper().serviceComponents.userRegistrationService
        
        XCTAssertNotNil(vc, "Could not instantiate MainViewController")
        _ = vc?.view
    }
    
}
