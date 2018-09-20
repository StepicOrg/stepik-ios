//
//  TrainingView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct TrainingViewData {
    let id: Int
    let title: String
    let description: String
    let countLessons: Int
    let isPractice: Bool
}

enum TrainingViewState {
    case idle
    case fetching
}

protocol TrainingView: class {
    var state: TrainingViewState { get set }

    func setViewData(_ viewData: [TrainingViewData])
    func displayError(title: String, message: String)
}
