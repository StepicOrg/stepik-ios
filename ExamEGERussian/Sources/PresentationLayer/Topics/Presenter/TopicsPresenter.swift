//
//  MainViewPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TopicsPresenter: class {
    func refresh()
    func selectTopic(with viewData: TopicsViewData)
    func selectSegment(at index: Int)
    func signIn()
    func logout()
}
