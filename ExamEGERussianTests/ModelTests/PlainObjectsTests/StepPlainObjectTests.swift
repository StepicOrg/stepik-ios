//
//  StepPlainObjectTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 14/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class StepPlainObjectTests: XCTestCase {
    private var step: StepPlainObject!

    override func setUp() {
        super.setUp()

        step = StepPlainObject.make()
    }

    override func tearDown() {
        super.tearDown()

        step = nil
    }

    func testStepType() {
        let map: [StepPlainObject.StepType: String] = [
            .text: "text", .choice: "choice", .string: "string", .number: "number",
            .freeAnswer: "free-answer", .math: "math", .sorting: "sorting", .matching: "matching",
            .fillBlanks: "fill-blanks", .code: "code", .sql: "sql", .table: "table", .video: "video",
            .dataset: "dataset", .admin: "admin"
        ]

        for (expectedType, rawValue) in map {
            if let instantiatedType = instantiateStepType(for: rawValue) {
                XCTAssertEqual(expectedType, instantiatedType)
            } else {
                XCTFail("Could't instantiate StepType for rawValue: \(rawValue)")
            }
        }
    }

    func testRandomStepImage() {
        for _ in 0...100 {
            let step = StepPlainObject.make()
            XCTAssertTrue(checkImage(for: step))
        }
    }

    func testStepTextTypeImage() {
        let textStep = StepPlainObject.make(type: .text)
        XCTAssertTrue(checkStepImage(textStep.image, type: .text))
    }

    func testStepVideoTypeImage() {
        let textStep = StepPlainObject.make(type: .video)
        XCTAssertTrue(checkStepImage(textStep.image, type: .video))
    }

    func testStepCodeTypeImage() {
        let textStep = StepPlainObject.make(type: .code)
        XCTAssertTrue(checkStepImage(textStep.image, type: .code))
    }

    func testStepDatasetTypeImage() {
        let textStep = StepPlainObject.make(type: .dataset)
        XCTAssertTrue(checkStepImage(textStep.image, type: .dataset))
    }

    func testStepAdminTypeImage() {
        let textStep = StepPlainObject.make(type: .admin)
        XCTAssertTrue(checkStepImage(textStep.image, type: .admin))
    }

    func testStepSQLTypeImage() {
        let textStep = StepPlainObject.make(type: .sql)
        XCTAssertTrue(checkStepImage(textStep.image, type: .sql))
    }

    func testStepFillBlanksTypeImage() {
        let textStep = StepPlainObject.make(type: .fillBlanks)
        XCTAssertTrue(checkStepImage(textStep.image, type: .fillBlanks))
    }

    func testStepCreation() {
        step = StepPlainObject(id: 1, lessonId: 2, position: 3, text: "Some text", type: .admin, progressId: "43", isPassed: true)
        XCTAssertEqual(step.id, 1)
        XCTAssertEqual(step.lessonId, 2)
        XCTAssertEqual(step.position, 3)
        XCTAssertEqual(step.text, "Some text")
        XCTAssertEqual(step.type, .admin)
        XCTAssertEqual(step.progressId, "43")
        XCTAssertEqual(step.isPassed, true)
    }

    func testStepProgressUpdate() {
        let originalProgress = step.isPassed
        step.setPassed(!originalProgress)

        XCTAssert(originalProgress != step.isPassed)
    }

    private func instantiateStepType(for rawValue: String) -> StepPlainObject.StepType? {
        return StepPlainObject.StepType(rawValue: rawValue)
    }

    private func checkImage(for step: StepPlainObject) -> Bool {
        return checkStepImage(step.image, type: step.type)
    }

    private func checkStepImage(_ image: UIImage, type: StepPlainObject.StepType) -> Bool {
        switch type {
        case .video:
            return image == ImageAsset.StepIcons.videoDark.image
        case .text:
            return image == ImageAsset.StepIcons.theoryDark.image
        case .code, .dataset, .admin, .sql:
            return image == ImageAsset.StepIcons.adminDark.image
        default:
            return image == ImageAsset.StepIcons.easyDark.image
        }
    }
}
