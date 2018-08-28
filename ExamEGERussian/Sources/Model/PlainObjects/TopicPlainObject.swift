//
//  TopicPlainObject.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 28/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct TopicPlainObject {
    let id: String
    let title: String
    let description: String
    let progress: Float
    let type: TopicType
    /// In minutes
    let timeToComplete: TimeInterval
    let lessons: [LessonPlainObject]

    enum TopicType {
        case theory
        case practice

        static let `default`: TopicType = .theory
    }
}
