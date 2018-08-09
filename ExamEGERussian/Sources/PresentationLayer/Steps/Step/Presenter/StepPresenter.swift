//
//  StepPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol StepPresenterDelegate: class {
    func stepSubmissionDidCorrect()
    func stepSubmissionDidWrong()
    func stepSubmissionDidRetry()
    func contentLoadingDidFail()
    func contentLoadingDidComplete()
}

extension StepPresenterDelegate {
    func stepSubmissionDidCorrect() {
    }

    func stepSubmissionDidWrong() {
    }

    func stepSubmissionDidRetry() {
    }

    func contentLoadingDidFail() {
    }

    func contentLoadingDidComplete() {
    }
}

enum StepPresenterState {
    case unsolved
    case wrong
    case successful
}

protocol StepPresenter: class {
    var delegate: StepPresenterDelegate? { get }
    var state: StepPresenterState { get set }

    func refreshStep()
}
