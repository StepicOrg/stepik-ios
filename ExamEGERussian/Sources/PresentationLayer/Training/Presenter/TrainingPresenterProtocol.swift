//
//  TrainingPresenterProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TrainingPresenterProtocol: class {
    func refresh()
    func selectTopic(_ topic: TopicPlainObject)
    func signIn()
    func logout()
}
