//
//  AdaptiveStepViewControllerDelegate.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 04.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol AdaptiveStepViewControllerDelegate: class {
    func stepSubmissionDidCorrect()
    func stepSubmissionDidWrong()
    func stepSubmissionDidRetry()
    func contentLoadingDidFail()
    func contentLoadingDidComplete()
}

extension AdaptiveStepViewControllerDelegate {
    func stepSubmissionDidCorrect() { }
    func stepSubmissionDidWrong() { }
    func stepSubmissionDidRetry() { }
    func contentLoadingDidFail() { }
    func contentLoadingDidComplete() { }
}
