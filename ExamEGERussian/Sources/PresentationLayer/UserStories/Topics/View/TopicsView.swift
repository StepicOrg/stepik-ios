//
//  MainView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct TopicsViewData {
    let title: String
    let onTap: () -> Void
}

protocol TopicsView: class {
    func setTopics(_ topics: [TopicsViewData])
    func displayError(title: String, message: String)
}
