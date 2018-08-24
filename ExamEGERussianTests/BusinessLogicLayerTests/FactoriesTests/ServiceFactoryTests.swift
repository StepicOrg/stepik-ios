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
    private var mockServiceFactory: ServiceFactory!
    private var concreateServiceFactory: ServiceFactory!

    override func setUp() {
        super.setUp()

        mockServiceFactory = ServiceFactoryMock()
        concreateServiceFactory = ServiceFactoryBuilder().build()
    }

    override func tearDown() {
        super.tearDown()

        mockServiceFactory = nil
        concreateServiceFactory = nil
    }

    func testMockServiceFactoryTypes() {
        XCTAssert(mockServiceFactory.userRegistrationService is UserRegistrationServiceMock)
        XCTAssert(mockServiceFactory.graphService is GraphServiceMock)
        XCTAssert(mockServiceFactory.lessonsService is LessonsServiceMock)
        XCTAssert(mockServiceFactory.courseService is CourseServiceMock)
        XCTAssert(mockServiceFactory.enrollmentService is EnrollmentServiceMock)
        XCTAssert(mockServiceFactory.stepsService is StepsServiceMock)
        XCTAssert(mockServiceFactory.progressService is ProgressServiceMock)
    }

    func testConcreateServiceFactoryTypes() {
        XCTAssert(concreateServiceFactory.userRegistrationService is UserRegistrationServiceImpl)
        XCTAssert(concreateServiceFactory.graphService is GraphService)
        XCTAssert(concreateServiceFactory.lessonsService is LessonsServiceImpl)
        XCTAssert(concreateServiceFactory.courseService is CourseServiceImpl)
        XCTAssert(concreateServiceFactory.enrollmentService is EnrollmentServiceImpl)
        XCTAssert(concreateServiceFactory.stepsService is StepsServiceImpl)
        XCTAssert(concreateServiceFactory.progressService is ProgressServiceImpl)
    }
}
