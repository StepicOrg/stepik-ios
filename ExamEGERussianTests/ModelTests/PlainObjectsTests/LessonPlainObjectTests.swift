//
//  LessonPlainObjectTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 14/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class LessonPlainObjectTests: XCTestCase {
    private var mathLesson: LessonPlainObject!
    private var frenchLesson: LessonPlainObject!

    override func setUp() {
        super.setUp()

        mathLesson = LessonPlainObject(id: 1, steps: [22, 23, 24], title: "Math", slug: "https://stepik.org")
        frenchLesson = LessonPlainObject(id: 2, steps: [11, 12, 14], title: "French", slug: "https://stepik.org")
    }

    override func tearDown() {
        mathLesson = nil
        frenchLesson = nil
    }

    func testInitFromLessonManagedObject() {
        let lesson = Lesson()
        lesson.title = "title"
        lesson.slug = "slug"
        lesson.stepsArray = [1, 2, 3, 4]

        let plainObject = LessonPlainObject(lesson: lesson)
        XCTAssertEqual(plainObject.id, lesson.id)
        XCTAssertEqual(plainObject.steps, lesson.stepsArray)
        XCTAssertEqual(plainObject.title, lesson.title)
        XCTAssertEqual(plainObject.slug, lesson.slug)
    }

    func testLesson() {
        XCTAssertEqual(mathLesson.id, 1)
        XCTAssertEqual(mathLesson.steps, [22, 23, 24])
        XCTAssertEqual(mathLesson.title, "Math")
        XCTAssertEqual(mathLesson.slug, "https://stepik.org")
    }

    func testEqualLessonsEquality() {
        let copy = mathLesson
        XCTAssert(copy == mathLesson)
    }

    func testDifferentLessonsEquality() {
        XCTAssert(mathLesson != frenchLesson)
    }

    func testArrayLessonsEquality() {
        let firstArray = [mathLesson, frenchLesson]
        let secondArray = [mathLesson]

        XCTAssert(firstArray != secondArray)
        XCTAssert(secondArray == [mathLesson])
    }

    func testLessonSlug() {
        XCTAssert(frenchLesson.slug.hasPrefix("https://"))
        XCTAssert(frenchLesson.slug.hasSuffix(".org"))
        XCTAssert(frenchLesson.slug.contains("stepik"))
    }

    func testNotEqualIds() {
        XCTAssertNotEqual(mathLesson.id, frenchLesson.id)
    }
}
