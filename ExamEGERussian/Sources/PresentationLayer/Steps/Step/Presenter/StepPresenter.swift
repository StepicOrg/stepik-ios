//
//  StepPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol StepPresenterDelegate: class {
    func stepPresenterSubmissionDidCorrect(_ stepPresenter: StepPresenter)
}

protocol StepPresenter: class {
    var step: StepPlainObject { get }
    var delegate: StepPresenterDelegate? { get set }

    func refreshStep()
}
