//
//  QuizViewControllerBuilderTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class QuizViewControllerBuilderTests: XCTestCase {
    var builder: QuizViewControllerBuilder!

    override func setUp() {
        super.setUp()
        builder = QuizViewControllerBuilder()
    }

    override func tearDown() {
        super.tearDown()
        builder = nil
    }

    func testQuizViewControllerBuilderSetStepType() {
        for stepType in StepPlainObject.allTypes {
            builder = builder.setStepType(stepType)
            XCTAssertNotNil(builder.stepType)
            XCTAssertEqual(builder.stepType!, stepType)
        }
    }

    func testQuizViewControllerBuilderSetLogoutable() {
        let logoutable = LogoutableMock()
        builder = builder.setLogoutable(logoutable)

        XCTAssertNotNil(builder.logoutable)
        XCTAssert(builder.logoutable! === logoutable)
    }

    func testQuizViewControllerBuilderBuild() {
        XCTAssertNil(builder.build())

        for stepType in StepPlainObject.allTypes {
            builder = builder.setStepType(stepType)
            let controller = builder.build()
            controller?.step = Step()

            switch stepType {
            case .choice:
                XCTAssert(controller is ExamChoiceQuizViewController)
            case .string:
                XCTAssert(controller is ExamStringQuizViewController)
            case .number:
                XCTAssert(controller is ExamNumberQuizViewController)
            default:
                XCTAssertNil(controller)
            }
        }
    }
}
