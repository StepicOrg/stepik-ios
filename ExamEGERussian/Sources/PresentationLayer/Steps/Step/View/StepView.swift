//
//  StepView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 01/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol StepView: class {
    func update(with htmlText: String)
    func updateQuiz(with controller: UIViewController)
    func displayError(title: String, message: String)
}
