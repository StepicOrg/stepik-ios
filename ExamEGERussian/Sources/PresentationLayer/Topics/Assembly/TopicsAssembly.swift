//
//  TopicsAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 25/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TopicsAssembly: class {
    func learning(navigationController: UINavigationController) -> UIViewController
    func training(navigationController: UINavigationController) -> UIViewController
}
