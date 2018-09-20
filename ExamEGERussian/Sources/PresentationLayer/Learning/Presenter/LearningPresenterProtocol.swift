//
//  LearningPresenterProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol LearningPresenterProtocol: class {
    func refresh()
    func selectViewData(_ viewData: LearningViewData)
}
