//
// CourseInfoTabInfoPresenterTests.swift
// stepik-ios
//
// Created by Ivan Magda on 11/16/18.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import XCTest
import Nimble

@testable import Stepic

class CourseInfoTabInfoPresenterTests: XCTestCase {
    var course: Course!
    var presenter: CourseInfoTabInfoPresenterProtocol!
    var viewControllerSpy: CourseInfoTabInfoViewControllerSpy!

    var viewModel: CourseInfoTabInfoViewModel! {
        if case .result(let viewModel) = self.viewControllerSpy.showInfoViewModel!.state {
            return viewModel
        } else {
            fail("Expected <CourseInfoTabInfoViewModel> got \(self.viewControllerSpy.showInfoViewModel!.state)")
            return nil
        }
    }

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
        expect(self.viewModel.aboutText) == expectedSummary
    }

    func testShowInfoRequirementsText() {
        let expectedRequirements = "requirements"
        self.course.requirements = expectedRequirements

        self.showInfo()
        expect(self.viewModel.requirementsText) == expectedRequirements
    }

    func testShowInfoTargetAudienceText() {
        let expectedTargetAudience = "targetAudience"
        self.course.audience = expectedTargetAudience

        self.showInfo()
        expect(self.viewModel.targetAudienceText) == expectedTargetAudience
    }

    private func showInfo() {
        self.presenter.presentCourseInfo(
            response: .init(course: self.course)
        )
    }
}
