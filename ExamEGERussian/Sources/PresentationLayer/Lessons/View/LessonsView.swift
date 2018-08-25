//
//  LessonsView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct LessonsViewData {
    let id: Int
    let title: String
    let subtitle: String
    let headerTitle: String
    let headerSubtitle: String
}

protocol LessonsView: class {
    func setLessons(_ lessons: [LessonsViewData])
    func displayError(title: String, message: String)
}
