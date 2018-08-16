//
//  KnowledgeGraphPlainObjectTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class KnowledgeGraphPlainObjectTests: XCTestCase {
    private var jsonData: Data!

    override func setUp() {
        super.setUp()

        let bundle = Bundle(for: KnowledgeGraphPlainObjectTests.self)
        let path = bundle.path(forResource: "knowledge-graph", ofType: "json")!
        let url = URL(fileURLWithPath: path)
        jsonData = try! Data(contentsOf: url, options: .mappedIfSafe)
    }

    override func tearDown() {
        super.tearDown()
        jsonData = nil
    }

    func testKnowledgeGraphDecoding() {
        let jsonDecoder = JSONDecoder()
        let graph = try? jsonDecoder.decode(KnowledgeGraphPlainObject.self, from: jsonData)

        XCTAssertNotNil(graph)
        XCTAssertEqual(graph!.goals.count, 1)
        XCTAssertEqual(graph!.topics.count, 2)
        XCTAssertEqual(graph!.topicsMap.count, 2)
    }
}
