//
//  GradientColorsResolverTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 06/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class GradientColorsResolverTests: XCTestCase {
    func testCorrectColorsResolve() {
        for i in 0...1000000 {
            XCTAssertEqual(
                GradientColorsResolver.resolve(i),
                GradientColorsResolver.resolve(i)
            )
        }
    }

    func testPerformanceExample() {
        self.measure {
            for i in 0...1000000 {
                _ = GradientColorsResolver.resolve(i)
            }
        }
    }
}
