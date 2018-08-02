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
    var topics: [TopicsViewData]?
    var displayErrorTitle: String?
    var displayErrorMessage: String?

    var onSet: (() -> Void)?
    var onError: (() -> Void)?

    func setTopics(_ topics: [TopicsViewData]) {
        self.topics = topics
        onSet?()
    }

    func displayError(title: String, message: String) {
        displayErrorTitle = title
        displayErrorMessage = message
        onError?()
    }
}
