//
//  QuizControllerDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

protocol QuizControllerDelegate: AnyObject {
    func submissionDidCorrect()
    func submissionDidWrong()
    func submissionDidRetry()
    func didWarningPlaceholderShow()
}

extension QuizControllerDelegate {
    func submissionDidCorrect() {}
    func submissionDidWrong() {}
    func submissionDidRetry() {}
    func didWarningPlaceholderShow() {}
}

protocol QuizControllerDataSource: AnyObject {
    var needsToRefreshAttemptWhenWrong: Bool { get }
    func getReply() -> Reply?
}
