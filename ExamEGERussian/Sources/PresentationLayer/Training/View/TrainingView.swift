//
//  TrainingView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TrainingView: class {
    func setTopics(_ topics: [TopicPlainObject])
    func displayError(title: String, message: String)
}
