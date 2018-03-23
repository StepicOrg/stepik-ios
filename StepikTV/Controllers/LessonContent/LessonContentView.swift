//
//  LessonContentView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 19.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol LessonContentView: class {

    func showLoading()

    func hideLoading()

    func provide(steps: [StepViewData])

    func update(at index: Int)
}
