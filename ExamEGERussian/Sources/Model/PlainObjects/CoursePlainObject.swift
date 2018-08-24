//
//  CoursePlainObject.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct CoursePlainObject {
    let id: Int
    let title: String
    let coverURLString: String
    let courseDescription: String
    let summary: String
    var enrolled = false
}

extension CoursePlainObject {
    init(course: Course) {
        self.id = course.id
        self.title = course.title
        self.coverURLString = course.coverURLString
        self.courseDescription = course.courseDescription
        self.summary = course.summary
        self.enrolled = course.enrolled
    }
}
