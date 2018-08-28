//
//  CoursePlainObjectTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 23/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class CoursePlainObjectTests: XCTestCase {
    func testInitFromCourseManagedObject() {
        let course = Course()
        course.title = "title"
        course.coverURLString = "coverURLString"
        course.courseDescription = "courseDescription"
        course.summary = "summary"
        course.enrolled = true

        let plainObject = CoursePlainObject(course: course)
        XCTAssertEqual(plainObject.id, course.id)
        XCTAssertEqual(plainObject.title, course.title)
        XCTAssertEqual(plainObject.coverURLString, course.coverURLString)
        XCTAssertEqual(plainObject.courseDescription, course.courseDescription)
        XCTAssertEqual(plainObject.summary, course.summary)
        XCTAssertEqual(plainObject.enrolled, course.enrolled)
    }
}
