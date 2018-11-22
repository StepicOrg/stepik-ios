//
// CourseInfoTabInfoAnalyticsProtocol.swift
// stepik-ios
//
// Created by Ivan Magda on 11/22/18.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol CourseInfoTabInfoAnalyticsProtocol {
    func reportContinuePressedForCourseWithId(_ id: Int, title: String)
}

struct CourseInfoTabInfoAnalytics: CourseInfoTabInfoAnalyticsProtocol {
    func reportContinuePressedForCourseWithId(_ id: Int, title: String) {
        AmplitudeAnalyticsEvents.Course.continuePressed(
            source: "course_info_tab",
            courseID: id,
            courseTitle: title
        ).send()
    }
}
