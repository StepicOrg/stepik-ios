//
//  QuizViewControllerBuilderProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 09/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol QuizViewControllerBuilderProtocol {
    var step: StepPlainObject { get }

    func build() -> QuizViewController?
}
