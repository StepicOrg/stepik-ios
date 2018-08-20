//
//  SendStepViewUseCaseProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 21/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol SendStepViewUseCaseProtocol: class {
    func sendView(for step: StepPlainObject) -> Promise<Void>
}
