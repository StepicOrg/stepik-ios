//
//  LessonsPresenterProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol LessonsPresenterProtocol: class {
    func refresh()
    func selectLesson(with viewData: LessonsViewData)
}
