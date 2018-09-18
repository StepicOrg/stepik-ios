//
//  AmplitudeAnalyticsEvents+Exam.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/09/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension AmplitudeAnalyticsEvents {
    struct Topic {
        static func opened(id: String, title: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Topic opened",
                parameters: [
                    "id": id,
                    "title": title
                ]
            )
        }
    }

    struct Lesson {
        static func opened(
            id: Int,
            type: String,
            courseId: String,
            topicId: String
        ) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Lesson opened",
                parameters: [
                    "id": id,
                    "type": type,
                    "course": courseId,
                    "topic": topicId
                ]
            )
        }
    }
}
