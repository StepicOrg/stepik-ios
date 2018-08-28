//
//  AssemblyFactoryTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class AssemblyFactoryTests: XCTestCase {
    var mockAssemblyFactory: AssemblyFactory!
    var concreateAssemblyFactory: AssemblyFactory!

    override func setUp() {
        super.setUp()

        mockAssemblyFactory = AssemblyFactoryMock()
        concreateAssemblyFactory = AssemblyFactoryBuilder(serviceFactory: ServiceFactoryMock()).build()
    }

    override func tearDown() {
        super.tearDown()

        mockAssemblyFactory = nil
        concreateAssemblyFactory = nil
    }

    func testMockAssemblyFactoryTypes() {
        XCTAssert(mockAssemblyFactory.applicationAssembly is ApplicationAssemblyMock)
        XCTAssert(mockAssemblyFactory.authAssembly is AuthAssemblyMock)
        XCTAssert(mockAssemblyFactory.authAssembly.greeting is AuthGreetingAssemblyMock)
        XCTAssert(mockAssemblyFactory.authAssembly.signIn is AuthSignInAssemblyMock)
        XCTAssert(mockAssemblyFactory.authAssembly.signUp is AuthSignUpAssemblyMock)
        XCTAssert(mockAssemblyFactory.topicsAssembly is TopicsAssemblyMock)
        XCTAssert(mockAssemblyFactory.lessonsAssembly is LessonsAssemblyMock)
        XCTAssert(mockAssemblyFactory.stepsAssembly is StepsAssemblyMock)
    }

    func testConcreateAssemblyFactoryTypes() {
        XCTAssert(concreateAssemblyFactory.applicationAssembly is ApplicationAssemblyImpl)
        XCTAssert(concreateAssemblyFactory.authAssembly is AuthAssemblyImpl)
        XCTAssert(concreateAssemblyFactory.authAssembly.greeting is AuthGreetingAssemblyImpl)
        XCTAssert(concreateAssemblyFactory.authAssembly.signIn is AuthSignInAssemblyImpl)
        XCTAssert(concreateAssemblyFactory.authAssembly.signUp is AuthSignUpAssemblyImpl)
        XCTAssert(concreateAssemblyFactory.topicsAssembly is TopicsAssemblyImpl)
        XCTAssert(concreateAssemblyFactory.lessonsAssembly is LessonsAssemblyImpl)
        XCTAssert(concreateAssemblyFactory.stepsAssembly is StepsAssembly)
        XCTAssert(concreateAssemblyFactory.stepsAssembly.standart is StandartStepsAssembly)
        XCTAssert(concreateAssemblyFactory.stepsAssembly.adaptive is AdaptiveStepsAssembly)
    }
}
