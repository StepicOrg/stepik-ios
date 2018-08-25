//
//  LessonViewModel.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 25/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct LessonViewModel {
    let lesson: LessonPlainObject
    let topic: KnowledgeGraphVertex<String>

    var title: String {
        return lesson.title
    }

    var subtitle: String {
        let type = topic.lessons.first(where: {
            $0.id == lesson.id
        })?.type ?? KnowledgeGraphLesson.LessonType.default

        switch type {
        case .theory:
            return pagesCountUniversal(count: UInt(lesson.steps.count))
        case .practice:
            return NSLocalizedString("PracticeLessonDescription", comment: "")
        }
    }

    private func pagesCountUniversal(count: UInt) -> String {
        let formatString = NSLocalizedString(
            "lesson pages count",
            comment: "Lessons pages count string format to be found in Localized.stringsdict"
        )
        let resultString = String.localizedStringWithFormat(formatString, count)

        return resultString
    }
}
