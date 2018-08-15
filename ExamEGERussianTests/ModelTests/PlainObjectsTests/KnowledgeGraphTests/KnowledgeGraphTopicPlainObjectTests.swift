//
//  KnowledgeGraphTopicPlainObjectTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class KnowledgeGraphTopicPlainObjectTests: XCTestCase {
    func testTopicJsonDecodingPartly() {
        let jsonString = """
{
    "id": "slitno-razdelno",
    "title": "B13 Слитное раздельное написание"
}
"""
        let jsonData = jsonString.data(using: .utf8)!

        let jsonDecoder = JSONDecoder()
        let decodedTopic = try? jsonDecoder.decode(KnowledgeGraphTopicPlainObject.self, from: jsonData)

        XCTAssertNotNil(decodedTopic, "Could't decode KnowledgeGraphTopicPlainObject)")
        XCTAssertEqual(decodedTopic!.id, "slitno-razdelno")
        XCTAssertEqual(decodedTopic!.title, "B13 Слитное раздельное написание")
    }

    func testTopicJsonDecodingFully() {
        let jsonString = """
{
    "id": "pristavki",
    "title": "B9 Приставки",
    "required-for": "slitno-razdelno"
}
"""
        let jsonData = jsonString.data(using: .utf8)!

        let jsonDecoder = JSONDecoder()
        let decodedTopic = try? jsonDecoder.decode(KnowledgeGraphTopicPlainObject.self, from: jsonData)

        XCTAssertNotNil(decodedTopic, "Could't decode KnowledgeGraphTopicPlainObject)")
        XCTAssertEqual(decodedTopic!.id, "pristavki")
        XCTAssertEqual(decodedTopic!.title, "B9 Приставки")
        XCTAssertNotNil(decodedTopic!.requiredFor)
        XCTAssertEqual(decodedTopic!.requiredFor, "slitno-razdelno")
    }

    func testTopicCodingKeys() {
        XCTAssertEqual(KnowledgeGraphTopicPlainObject.CodingKeys.id.rawValue, "id")
        XCTAssertEqual(KnowledgeGraphTopicPlainObject.CodingKeys.title.rawValue, "title")
        XCTAssertEqual(KnowledgeGraphTopicPlainObject.CodingKeys.requiredFor.rawValue, "required-for")
    }

    func testTopicAllValues() {
        let topic = KnowledgeGraphTopicPlainObject(id: "pristavki", title: "B9 Приставки",
                                                   requiredFor: "slitno-razdelno")
        XCTAssertEqual(topic.id, "pristavki")
        XCTAssertEqual(topic.title, "B9 Приставки")
        XCTAssertNotNil(topic.requiredFor)
        XCTAssertEqual(topic.requiredFor!, "slitno-razdelno")
    }
}
