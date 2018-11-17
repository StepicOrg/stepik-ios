//
// CourseInfoTabInfoPresenterTests.swift
// stepik-ios
//
// Created by Ivan Magda on 11/16/18.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import XCTest

@testable import Stepic

class CourseInfoTabInfoPresenterTests: XCTestCase {
    var course: Course!
    var presenter: CourseInfoTabInfoPresenterProtocol!
    var viewControllerSpy: CourseInfoTabInfoViewControllerSpy!

    override func setUp() {
        super.setUp()

        self.course = Course()
        self.viewControllerSpy = CourseInfoTabInfoViewControllerSpy()

        let concretePresenter = CourseInfoTabInfoPresenter()
        concretePresenter.viewController = self.viewControllerSpy
        self.presenter = concretePresenter
    }

    override func tearDown() {
        super.tearDown()

        self.course = nil
        self.viewControllerSpy = nil
        self.presenter = nil
    }

    func testShowInfoLoadingState() {
        self.course = nil

        self.showInfo()

        if case .loading = self.viewControllerSpy.showInfoViewModel!.state {
        } else {
            XCTFail("Expected `.loading` state")
        }
    }

    func testShowInfoResultState() {
        self.showInfo()

        if let viewModel = self.viewControllerSpy.showInfoViewModel,
           case .result = viewModel.state {
        } else {
            XCTFail("Expected `.result` state")
        }
    }

    func testShowInfoAboutText() {
        let expectedSummary = "summary"
        self.course.summary = expectedSummary

        self.showInfo()

        if case .result(let data) = self.viewControllerSpy.showInfoViewModel!.state {
            XCTAssertEqual(data.aboutText, expectedSummary)
        } else {
            XCTFail("Summaries not equal")
        }
    }

    func testShowInfoRequirementsText() {
        let expectedRequirements = "requirements"
        self.course.requirements = expectedRequirements

        self.showInfo()

        if case .result(let data) = self.viewControllerSpy.showInfoViewModel!.state {
            XCTAssertEqual(data.requirementsText, expectedRequirements)
        } else {
            XCTFail("Requirements not equal")
        }
    }

    func testShowInfoTargetAudienceText() {
        let expectedTargetAudience = "targetAudience"
        self.course.audience = expectedTargetAudience

        self.showInfo()

        if case .result(let data) = self.viewControllerSpy.showInfoViewModel!.state {
            XCTAssertEqual(data.targetAudienceText, expectedTargetAudience)
        } else {
            XCTFail("Target audience texts not equal")
        }
    }

    private func showInfo() {
        self.presenter.presentCourseInfo(
            response: .init(course: self.course)
        )
    }
}
