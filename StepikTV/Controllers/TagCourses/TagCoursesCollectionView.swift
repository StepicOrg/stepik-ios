//
//  TagCoursesCollectionView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 02.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

protocol TagCoursesCollectionView: class {

    func showLoading(isVisible: Bool)

    func provide(items: [ItemViewData])

}
