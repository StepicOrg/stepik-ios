//
//  AdaptiveStepView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum AdaptiveStepsViewState {
    case idle
    case fetching
    case coursePassed
    case connectionError
}

protocol AdaptiveStepsView: class {
    var state: AdaptiveStepsViewState { get set }

    func addContentController(_ controller: UIViewController)
    func removeContentController(_ controller: UIViewController)

    func updateTitle(_ title: String)
}
