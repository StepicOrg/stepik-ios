//
//  StandartStepsAssemblyProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 02/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit.UINavigationController

protocol StandartStepsAssemblyProtocol: class {
    func module(navigationController: UINavigationController, lesson: LessonPlainObject) -> UIViewController
}
