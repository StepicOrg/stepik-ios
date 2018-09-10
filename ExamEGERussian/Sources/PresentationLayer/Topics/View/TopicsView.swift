//
//  MainView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct TopicsViewData {
    let id: String
    let title: String
}

protocol TopicsView: class {
    func setTopics(_ topics: [TopicsViewData])
    func setSegments(_ segments: [String])
    func selectSegment(at index: Int)
    func displayError(title: String, message: String)
}
