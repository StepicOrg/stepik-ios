//
//  CatalogView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 12.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CatalogView: class {

    func provide(count: Int, at indexPath: IndexPath)
}

protocol DetailCatalogView: class {

    func showLoading(isVisible: Bool)

    func provide(items: [ItemViewData])

    func update()
}
