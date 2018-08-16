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
        serviceFactory = ServiceFactoryMock()
    }

    override func tearDown() {
        super.tearDown()
        serviceFactory = nil
    }

    func testServiceFactoryNotNil() {
        XCTAssertNotNil(serviceFactory, "Could't instantiate ServiceFactory")
    }

    func testMockServiceFactoryTypes() {
        XCTAssert(serviceFactory!.userRegistrationService is UserRegistrationServiceMock)
        XCTAssert(serviceFactory!.graphService is GraphServiceMock)
        XCTAssert(serviceFactory!.lessonsService is LessonsServiceMock)
        XCTAssert(serviceFactory!.courseService is CourseServiceMock)
        XCTAssert(serviceFactory!.enrollmentService is EnrollmentServiceMock)
        XCTAssert(serviceFactory!.stepsService is StepsServiceMock)
        XCTAssert(serviceFactory!.progressService is ProgressServiceMock)
    }

    func testConcreateServiceFactoryTypes() {
        let serviceFactory = ServiceFactoryBuilder().build() as! ServiceFactoryImpl
        XCTAssert(serviceFactory.userRegistrationService is UserRegistrationServiceImpl)
        XCTAssert(serviceFactory.graphService is GraphServiceImpl)
        XCTAssert(serviceFactory.lessonsService is LessonsServiceImpl)
        XCTAssert(serviceFactory.courseService is CourseServiceImpl)
        XCTAssert(serviceFactory.enrollmentService is EnrollmentServiceImpl)
        XCTAssert(serviceFactory.stepsService is StepsServiceImpl)
        XCTAssert(serviceFactory.progressService is ProgressServiceImpl)
    }
}
