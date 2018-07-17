//
//  MainView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol MainView: class {
    func setTitle(_ title: String)
    func setGreetingText(_ text: String)
    func setRightBarButtonItemTitle(_ title: String)
}
