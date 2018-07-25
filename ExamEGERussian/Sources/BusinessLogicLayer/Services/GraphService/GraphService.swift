//
//  GraphService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol GraphService: class {
    func obtainGraph() -> Promise<KnowledgeGraphPlainObject>
}
