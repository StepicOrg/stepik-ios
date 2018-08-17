//
//  LessonMapper.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class LessonMapper {
    private let lesson: Lesson

    var plainObject: LessonPlainObject {
        return LessonPlainObject(id: lesson.id, steps: lesson.stepsArray, title: lesson.title, slug: lesson.slug)
    }

    init(lesson: Lesson) {
        self.lesson = lesson
    }
}
