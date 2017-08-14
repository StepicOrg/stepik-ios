//
//  CertificatesAPITest.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest
import UIKit
@testable import Stepic

class CertificatesAPITests: XCTestCase {

    let certificates = CertificatesAPI()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetCertificates() {
        let expectation = self.expectation(description: "testGetCertificates")

        certificates.retrieve(userId: 1718803, page: 1, success: {
            _, certificates in
            print(certificates)
            expectation.fulfill()
        }, error: {
            error in
            XCTAssert(false, "error \(error)")
        })

        waitForExpectations(timeout: 10.0) {
            error in
            if error != nil {
                XCTAssert(false, "Timeout error")
            }
        }
    }

    func testUpdateCertificates() {
        let expectation = self.expectation(description: "testUpdateCertificates")

        let cert = Certificate()
        cert.id = 8715
        cert.grade = 50

        certificates.retrieve(userId: 1718803, page: 1, success: {
            _, certificates in
            print(certificates)
            expectation.fulfill()
        }, error: {
            error in
            XCTAssert(false, "error \(error)")
        })

        waitForExpectations(timeout: 10.0) {
            error in
            if error != nil {
                XCTAssert(false, "Timeout error")
            }
        }
    }
}
