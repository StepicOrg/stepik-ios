//
//  CatalogView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 12.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CatalogMenuView: class {

    func provide(count: Int, at indexPath: IndexPath)
}

protocol CatalogDetailView: class {

    func showLoading(with width: Float)

    func hideLoading()

    func provide(items: [ItemViewData])

    func update()
}
