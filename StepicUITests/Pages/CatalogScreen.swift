//
//  CatalogScreen.swift
//  StepicUITests
//
//  Created by admin on 25.05.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

class CatalogScreen: BaseScreen {

    private lazy var btnRu = app.buttons["Ru"]
    private lazy var btnEn = app.buttons["En"]

    
    func selectRuLanguage() {
        XCTAssertTrue(btnRu.waitForExistence(timeout: 10), "No 'Ru' button")
        btnRu.tap()
    }

    func selectEnLanguage() {
        XCTAssertTrue(btnEn.waitForExistence(timeout: 10), "No 'En' button")
        btnEn.tap()
    }
    
    func shouldNotBeLanguageButtons() {
        XCTAssertFalse(btnRu.waitForExistence(timeout: 5), "'En' button exists")
        XCTAssertFalse(btnEn.waitForExistence(timeout: 5), "'Ru' button exists")
    }
}
