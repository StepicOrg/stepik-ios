//
//  CourseMapper.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class CourseMapper {
    private let course: Course

    var plainObject: CoursePlainObject {
        return CoursePlainObject(
            id: course.id,
            title: course.title,
            coverURLString: course.coverURLString,
            courseDescription: course.courseDescription,
            summary: course.summary,
            enrolled: course.enrolled
        )
    }

    init(course: Course) {
        self.course = course
    }
}
