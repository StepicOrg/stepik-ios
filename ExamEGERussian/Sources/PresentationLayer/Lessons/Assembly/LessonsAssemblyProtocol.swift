//
//  LessonsAssemblyProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 30/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol LessonsAssemblyProtocol: class {
    func module(
        navigationController: UINavigationController,
        topicId: String
    ) -> UIViewController
}
