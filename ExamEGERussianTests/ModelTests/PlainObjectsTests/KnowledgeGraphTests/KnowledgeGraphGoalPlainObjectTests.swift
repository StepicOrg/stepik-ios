//
//  KnowledgeGraphGoalPlainObjectTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class KnowledgeGraphGoalPlainObjectTests: XCTestCase {
    func testGoalJsonDecoding() {
        let jsonString = """
{
    "title": "Морфология",
    "id": "morph",
    "required-topics": [
        "slitno-razdelno"
    ]
}
"""
        let jsonData = jsonString.data(using: .utf8)!

        let jsonDecoder = JSONDecoder()
        let decodedGoal = try? jsonDecoder.decode(KnowledgeGraphGoalPlainObject.self, from: jsonData)

        XCTAssertNotNil(decodedGoal, "Could't decode KnowledgeGraphGoalPlainObject")
        XCTAssertEqual(decodedGoal!.title, "Морфология")
        XCTAssertEqual(decodedGoal!.id, "morph")
        XCTAssertEqual(decodedGoal!.requiredTopics.count, 1)
        XCTAssertNotNil(decodedGoal!.requiredTopics.first)
        XCTAssertEqual(decodedGoal!.requiredTopics.first!, "slitno-razdelno")
    }

    func testGoalCreation() {
        let goal = KnowledgeGraphGoalPlainObject(title: "title", id: "id", requiredTopics: ["topic"])
        XCTAssertEqual(goal.title, "title")
        XCTAssertEqual(goal.id, "id")
        XCTAssertEqual(goal.requiredTopics.count, 1)
        XCTAssertEqual(goal.requiredTopics.first!, "topic")
    }
}
