//
// HTMLParsingTests.swift
// Stepic
//
// Created by Alexander Karpov on 01.06.16.
// Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest
@testable import Stepic

class HTMLParsingTests: XCTestCase {

    struct HTMLStrings {
        static let latex = "Square of x is $x^2$"
        static let nonLatex = "Wow! I have won 100$!"
        static let imageSimple = "Look at this image! <img src=\"some/random/image.jpg\">"
        static let imageWithStyle = "Wow great image I found in the internet! <img src=\"image/girl.jpg\" width=\"120\" height=\"120\" alt=\"Девочка с муфтой\"> Yeah!"
        static let noImage = "no img here, even if I write <img without closing the tag baby!"
        static let code = "Isn't this code perfect? <code> I'm perfect! </code>"
        static let noCode = "Your code is worse than code of my grandmother"
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLatexDetection() {
        XCTAssert(TagDetectionUtil.detectLaTeX(HTMLStrings.latex))
        XCTAssertFalse(TagDetectionUtil.detectLaTeX(HTMLStrings.nonLatex))
    }

    func testImageDetection() {
        XCTAssert(TagDetectionUtil.detectImage(HTMLStrings.imageSimple))
        XCTAssert(TagDetectionUtil.detectImage(HTMLStrings.imageWithStyle))
        XCTAssertFalse(TagDetectionUtil.detectImage(HTMLStrings.noImage))
    }

    func testCodeDetection() {
        XCTAssert(TagDetectionUtil.detectCode(HTMLStrings.code))
        XCTAssertFalse(TagDetectionUtil.detectCode(HTMLStrings.noCode))
    }
}
