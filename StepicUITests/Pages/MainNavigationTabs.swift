//
//  MainNavigationTabs.swift
//  StepicUITests
//
//  Created by admin on 19.05.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

class MainNavigationTabs: BaseScreen {

    private lazy var btnProfile = app.tabBars.buttons[AccessibilityIdentifiers.TabBar.profile]
    private lazy var btnCatalog = app.tabBars.buttons[AccessibilityIdentifiers.TabBar.catalog]
    
    func openProfile() {
        XCTAssertTrue(btnProfile.waitForExistence(timeout: 10), "No 'Profile' tab")
        btnProfile.tap()
    }
    
    func openCatalog() {
        XCTAssertTrue(btnCatalog.waitForExistence(timeout: 10), "No 'Catalog' tab")
        btnCatalog.tap()
    }
    
}

