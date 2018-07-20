//
//  MainViewPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TopicsPresenter: class {
    var numberOfTopics: Int { get }

    func viewDidLoad()
    func configure(cell: TopicCellView, forRow row: Int)
    func didSelect(row: Int)
    func didPullToRefresh()
    func titleForScene() -> String
}
