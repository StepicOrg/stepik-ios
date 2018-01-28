//
//  CatalogView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 12.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CatalogView: class {

    func showNoticeMessage()
}

protocol DetailCatalogView: class {

    func showLoading(isVisible: Bool)

    func provide(items: [ItemViewData])

    func update()

}
