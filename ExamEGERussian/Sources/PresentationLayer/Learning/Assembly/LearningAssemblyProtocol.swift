//
//  LearningAssemblyProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol LearningAssemblyProtocol: class {
    func makeModule(navigationController: UINavigationController) -> UIViewController
}
