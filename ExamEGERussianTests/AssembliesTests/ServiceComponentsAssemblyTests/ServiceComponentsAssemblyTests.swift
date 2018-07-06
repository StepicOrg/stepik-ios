//
//  ServiceComponentsAssemblyTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 05/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class ServiceComponentsAssemblyTests: XCTestCase {
    
    private var serviceComponents: ServiceComponents?
    
    override func setUp() {
        super.setUp()
        
        serviceComponents = ServiceComponentsAssemblyTestsHelper().serviceComponents
    }
    
    override func tearDown() {
        super.tearDown()
        
        serviceComponents = nil
    }
    
    func testServiceComponentsCreation() {
        XCTAssertNotNil(serviceComponents, "ServiceComponents doesn't exists")
    }
    
}
