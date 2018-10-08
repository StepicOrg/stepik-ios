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
}

enum LessonsViewState {
    case idle
    case fetching
}

protocol LessonsView: class {
    var state: LessonsViewState { get set }

    func setLessons(_ lessons: [LessonsViewData])
    func updateHeader(title: String, subtitle: String, colors: [UIColor])
    func displayError(title: String, message: String)
}
