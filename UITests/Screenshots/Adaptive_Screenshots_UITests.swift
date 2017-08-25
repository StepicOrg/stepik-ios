//
//  Adaptive_Screenshots_UITests.swift
//  Adaptive Screenshots UITests
//
//  Created by Vladislav Kiryukhin on 24.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import XCTest
import SimulatorStatusMagic

class XCTestCaseSwizzledIdle: XCTestCase {
    static var swizzledOutIdle = false

    override func setUp() {
        if !XCTestCaseSwizzledIdle.swizzledOutIdle {
            let original = class_getInstanceMethod(objc_getClass("XCUIApplicationProcess") as! AnyClass, Selector(("waitForQuiescenceIncludingAnimationsIdle:")))
            let replaced = class_getInstanceMethod(type(of: self), #selector(XCTestCaseSwizzledIdle.replace))
            method_exchangeImplementations(original, replaced)
            XCTestCaseSwizzledIdle.swizzledOutIdle = true
        }
        super.setUp()
    }
    
    @objc func replace() {
        return
    }
}

class Adaptive_Screenshots_UITests: XCTestCaseSwizzledIdle {

    override func setUp() {
        super.setUp()

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        SDStatusBarManager.sharedInstance().enableOverrides()
    }

    func testTakeScreenshots() {
        // Waiting for Koloda
        sleep(10)

        // Card (from UI recording)
        let card = XCUIApplication().otherElements.containing(.button, identifier:"trophy").children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element

        // Default card state
        snapshot("1card")

        // Left swipe
        var start = card.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.2))
        var finish = card.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            snapshot("3hard")
        }

        start.press(forDuration: 0, thenDragTo: finish)
        sleep(3)

        // Right swipe
        start = card.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.2))
        finish = card.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.5))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            snapshot("4simple")
        }

        start.press(forDuration: 0, thenDragTo: finish)
        sleep(3)

        // Loading card state
        card.swipeLeft()
        sleep(1)
        snapshot("2load")
    }
}
