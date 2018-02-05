//
//  CourseInfoView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseInfoView: class {

    func provide(sections: [CourseInfoSection])

    func showLoading(title: String)

    func hideLoading()

    func dismissOnUnsubscribe()

}
