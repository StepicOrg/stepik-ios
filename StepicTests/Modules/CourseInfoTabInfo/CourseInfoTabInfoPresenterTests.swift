//
// CourseInfoTabInfoPresenterTests.swift
// stepik-ios
//
// Created by Ivan Magda on 11/16/18.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble

@testable import Stepic

class CourseInfoTabInfoPresenterTests: QuickSpec {
    override func spec() {
        describe("a presenter") {
            var course: Course!
            var presenter: CourseInfoTabInfoPresenterProtocol!
            var viewControllerSpy: CourseInfoTabInfoViewControllerSpy!

            beforeEach {
                course = Course()
                viewControllerSpy = CourseInfoTabInfoViewControllerSpy()

                let concretePresenter = CourseInfoTabInfoPresenter()
                concretePresenter.viewController = viewControllerSpy
                presenter = concretePresenter
            }

            describe("its shows info") {
                var actualViewModel: CourseInfoTabInfoViewModel! {
                    if case .result(let viewModel) = viewControllerSpy.invokedShowInfoViewModel!.state {
                        return viewModel
                    } else {
                        fail("Expected `CourseInfoTabInfoViewModel` got \(viewControllerSpy.invokedShowInfoViewModel!.state)")
                        return nil
                    }
                }

                func configureAndShow(_ configure: (Course) -> Void) {
                    configure(course)
                    showInfo()
                }

                func showInfo() {
                    presenter.presentCourseInfo(response: .init(course: course))
                }

                it("is in loading state") {
                    course = nil
                    showInfo()

                    expect(viewControllerSpy.invokedDisplayCourseInfo).to(beTrue())
                    expect(viewControllerSpy.invokedDisplayCourseInfoCount) == 1

                    if case .loading = viewControllerSpy.invokedShowInfoViewModel!.state {
                    } else {
                        fail("Expected `.loading` state")
                    }
                }

                it("has returned actual data") {
                    configureAndShow { _ in
                    }

                    expect(viewControllerSpy.invokedDisplayCourseInfo).to(beTrue())
                    expect(viewControllerSpy.invokedDisplayCourseInfoCount) == 1

                    if let viewModel = viewControllerSpy.invokedShowInfoViewModel,
                       case .result = viewModel.state {
                    } else {
                        fail("Expected `.result` state")
                    }
                }

                it("has returned expected about text") {
                    let expectedSummary = "summary"
                    configureAndShow { course in
                        course.summary = expectedSummary
                    }

                    expect(viewControllerSpy.invokedDisplayCourseInfo).to(beTrue())
                    expect(viewControllerSpy.invokedDisplayCourseInfoCount) == 1
                    expect(actualViewModel.aboutText) == expectedSummary
                }

                it("has returned expected requirements text") {
                    let expectedRequirements = "requirements"
                    configureAndShow { course in
                        course.requirements = expectedRequirements
                    }

                    expect(viewControllerSpy.invokedDisplayCourseInfo).to(beTrue())
                    expect(viewControllerSpy.invokedDisplayCourseInfoCount) == 1
                    expect(actualViewModel.requirementsText) == expectedRequirements
                }

                it("has returned expected target audience text") {
                    let expectedTargetAudience = "targetAudience"
                    configureAndShow { course in
                        course.audience = expectedTargetAudience
                    }

                    expect(viewControllerSpy.invokedDisplayCourseInfo).to(beTrue())
                    expect(viewControllerSpy.invokedDisplayCourseInfoCount) == 1
                    expect(actualViewModel.targetAudienceText) == expectedTargetAudience
                }
            }
        }
    }
}
