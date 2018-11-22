//
// CourseInfoTabInfoOutputProtocol.swift
// stepik-ios
//
// Created by Ivan Magda on 11/22/18.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol CourseInfoTabInfoOutputProtocol: class {
    func presentLastStep(course: Course, isAdaptive: Bool)
    func presentAuthorization()
}
