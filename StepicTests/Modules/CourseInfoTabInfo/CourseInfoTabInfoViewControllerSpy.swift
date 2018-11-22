//
// CourseInfoTabInfoViewControllerSpy.swift
// stepik-ios
//
// Created by Ivan Magda on 11/16/18.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation

@testable import Stepic

final class CourseInfoTabInfoViewControllerSpy: CourseInfoTabInfoViewControllerProtocol {
    var invokedDisplayCourseInfo = false
    var invokedDisplayCourseInfoCount = 0
    var invokedShowInfoViewModel: CourseInfoTabInfo.ShowInfo.ViewModel?

    var invokedShowLoadingIndicator = false
    var invokedShowLoadingIndicatorCount = 0

    var invokedHideLoadingIndicator = false
    var invokedHideLoadingIndicatorCount = 0

    var invokedShowErrorIndicator = false
    var invokedShowErrorIndicatorCount = 0
    var invokedShowErrorIndicatorMessage: String?

    func displayCourseInfo(viewModel: CourseInfoTabInfo.ShowInfo.ViewModel) {
        self.invokedDisplayCourseInfo = true
        self.invokedDisplayCourseInfoCount += 1
        self.invokedShowInfoViewModel = viewModel
    }

    func showLoadingIndicator() {
        self.invokedShowLoadingIndicator = true
        self.invokedShowLoadingIndicatorCount += 1
    }

    func hideLoadingIndicator() {
        self.invokedHideLoadingIndicator = true
        self.invokedHideLoadingIndicatorCount += 1
    }

    func showErrorIndicator(message: String?) {
        self.invokedShowErrorIndicator = true
        self.invokedShowErrorIndicatorCount += 1
        self.invokedShowErrorIndicatorMessage = message
    }
}
