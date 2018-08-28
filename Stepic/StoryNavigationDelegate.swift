//
//  StoryNavigationDelegate.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol StoryNavigationDelegate: class {
    func didFinishForward()
    func didFinishBack()
}
