//
//  TopicsViewSpy.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 23/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class TopicsViewSpy: TopicsView {
    var refreshTopicsViewCalled = false
    var displayErrorTitle: String?
    var displayErrorMessage: String?

    func refreshTopicsView() {
        refreshTopicsViewCalled = true
    }

    func displayError(title: String, message: String) {
        displayErrorTitle = title
        displayErrorMessage = message
    }
}
