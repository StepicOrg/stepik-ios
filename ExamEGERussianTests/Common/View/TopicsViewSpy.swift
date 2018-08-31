//
//  TopicsViewSpy.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 23/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class TopicsViewSpy: TrainingView {
    var topics: [TopicPlainObject]?
    var displayErrorTitle: String?
    var displayErrorMessage: String?

    var onSet: (() -> Void)?
    var onError: (() -> Void)?

    func setTopics(_ topics: [TopicPlainObject]) {
        self.topics = topics
        onSet?()
    }

    func displayError(title: String, message: String) {
        displayErrorTitle = title
        displayErrorMessage = message
        onError?()
    }

    // TODO: Test this
    func setSegments(_ segments: [String]) {

    }

    // TODO: Test this
    func selectSegment(at index: Int) {

    }
}
