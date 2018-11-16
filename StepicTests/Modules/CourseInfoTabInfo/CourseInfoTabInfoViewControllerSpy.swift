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
    var showInfoViewModel: CourseInfoTabInfo.ShowInfo.ViewModel?

    func displayCourseInfo(viewModel: CourseInfoTabInfo.ShowInfo.ViewModel) {
        self.showInfoViewModel = viewModel
    }
}
