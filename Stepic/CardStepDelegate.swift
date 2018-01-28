//
//  CardStepDelegate.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol CardStepDelegate: class {
    func stepSubmissionDidCorrect()
    func stepSubmissionDidWrong()
    func stepSubmissionDidRetry()
    func contentLoadingDidFail()
    func contentLoadingDidComplete()
}

extension CardStepDelegate {
    func stepSubmissionDidCorrect() { }
    func stepSubmissionDidWrong() { }
    func stepSubmissionDidRetry() { }
    func contentLoadingDidFail() { }
    func contentLoadingDidComplete() { }
}
