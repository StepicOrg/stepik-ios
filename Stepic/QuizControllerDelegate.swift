//
//  QuizControllerDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

protocol QuizControllerDelegate: class {
    func needsHeightUpdate(_ newHeight: CGFloat, animated: Bool, breaksSynchronizationControl: Bool)
}
