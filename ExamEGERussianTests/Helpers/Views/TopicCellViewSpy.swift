//
//  TopicCellViewSpy.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 23/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class TopicCellViewSpy: TopicCellView {
    var displayedTitle = ""

    func display(title: String) {
        displayedTitle = title
    }
}
