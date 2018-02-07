//
//  SearchResultsView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 06.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

protocol SearchResultsView: class {

    func showLoading(isVisible: Bool)

    func provide(items: [ItemViewData])

}
