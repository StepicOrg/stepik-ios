//
//  GraphService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol GraphService: class {
    typealias Handler = (StepicResult<KnowledgeGraphPlainObject>) -> Void
    func obtainGraph(_ completionHandler: @escaping Handler)
}
