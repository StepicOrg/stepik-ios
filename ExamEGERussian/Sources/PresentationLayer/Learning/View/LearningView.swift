//
//  LearningView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct LearningViewData {
    let id: String
    let title: String
    let description: String
    let timeToComplete: String
    let progress: String
}

protocol LearningView: class {
    func setViewData(_ viewData: [LearningViewData])
    func displayError(title: String, message: String)
}
