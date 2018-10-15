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
        XCTAssertEqual(graph!.goals.count, 6)
        XCTAssertEqual(graph!.topics.count, 10)
        XCTAssertEqual(graph!.topicsMap.count, graph!.topics.count)

        XCTAssertTrue(
            graph!.goals.contains(where: {
                $0.title == "Системы счисления"
            })
        )
        XCTAssertTrue(
            graph!.topics.contains(where: {
                $0.description == "Анализ информационных моделей и поиск путей в графе"
            })
        )
    }
}
