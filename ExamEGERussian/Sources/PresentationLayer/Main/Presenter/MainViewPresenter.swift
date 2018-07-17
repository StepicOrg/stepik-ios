//
//  MainViewPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol MainViewPresenter {
    var router: MainViewRouter { get }

    func viewDidLoad()
    func viewWillAppear()
    func rightBarButtonPressed()
    func titleForRightBarButtonItem() -> String
}
