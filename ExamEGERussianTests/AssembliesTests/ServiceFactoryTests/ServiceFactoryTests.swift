//
//  ServiceComponentsAssemblyTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 05/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class ServiceFactoryTests: XCTestCase {

    private var serviceFactory: ServiceFactory?

    override func setUp() {
        super.setUp()

        serviceFactory = ServiceFactoryTestsHelper().serviceFactory
    }

    override func tearDown() {
        super.tearDown()

        serviceFactory = nil
    }

    func testServiceComponentsCreation() {
        XCTAssertNotNil(serviceFactory, "Could not instantiate ServiceFactory")
    }

}
