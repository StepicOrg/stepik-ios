//
//  QuizControllerDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

protocol QuizControllerDelegate: class {
    func submissionDidCorrect()
    func submissionDidWrong()
    func submissionDidRetry()
    func didWarningPlaceholderShow()
}

extension QuizControllerDelegate {
    func submissionDidCorrect() { }
    func submissionDidWrong() { }
    func submissionDidRetry() { }
    func didWarningPlaceholderShow() { }
}

protocol QuizControllerDataSource: class {
    var needsToRefreshAttemptWhenWrong: Bool { get }
    func getReply() -> Reply?
}
