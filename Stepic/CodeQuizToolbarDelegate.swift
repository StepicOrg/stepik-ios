//
//  CodeQuizToolbarDelegate.swift
//  Stepic
//
//  Created by Ostrenkiy on 23.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol CodeQuizToolbarDelegate: class {
    func changeLanguagePressed()
    func fullscreenPressed()
    func resetPressed()
}
