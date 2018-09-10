//
//  TopicsRouter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 26/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TopicsRouter: class {
    func showAuth()
    func showLessonsForTopicWithId(_ id: String)
    func showAdaptiveForTopicWithId(_ id: String)
}
