//
//  TagsTagsPresenter.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol TagsPresenterProtocol {
    func presentTags(response: Tags.ShowTags.Response)
}

final class TagsPresenter: TagsPresenterProtocol {
    weak var viewController: TagsViewControllerProtocol?

    func presentTags(response: Tags.ShowTags.Response) {
        let state: Tags.ViewControllerState = {
            switch response.result {
            case .success(let tags):
                return Tags.ViewControllerState.result(
                    data: tags.map { TagViewModel(title: $0.title) }
                )
            case .failure:
                return Tags.ViewControllerState.emptyResult
            }
        }()

        let viewModel = Tags.ShowTags.ViewModel(state: state)

        viewController?.displayTags(viewModel: viewModel)
    }
}
