//
//  UITableViewExtensionsTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
import UIKit
@testable import ExamEGERussian

class UITableViewExtensionsTests: XCTestCase {
    var tableView: UITableView!
    var tableCell: UITableViewCell!
    var headerFooterCell: UITableViewHeaderFooterView!

    override func setUp() {
        super.setUp()
        
        tableView = UITableView()
        tableView.registerClass(for: MockTableViewCell.self)
        tableView.registerHeaderNib(for: UITableViewHeaderFooterView.self)
        tableView.register(
            MockTableViewHeaderFooterView.self,
            forHeaderFooterViewReuseIdentifier: String(describing: MockTableViewHeaderFooterView.self)
        )
    }

    override func tearDown() {
        super.tearDown()
        tableView = nil
    }

    func testDequeueReusableCell() {
        tableCell = tableView.dequeueReusableCell(for: IndexPath(index: 0)) as MockTableViewCell
        XCTAssert(tableCell is MockTableViewCell)
    }

    func testDequeueReusableHeaderFooterView() {
        headerFooterCell = tableView.dequeueReusableHeaderFooterView() as MockTableViewHeaderFooterView
        XCTAssert(headerFooterCell is MockTableViewHeaderFooterView)
    }
}
