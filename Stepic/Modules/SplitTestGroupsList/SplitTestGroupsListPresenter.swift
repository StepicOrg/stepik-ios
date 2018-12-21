//
//  SplitTestGroupsListSplitTestGroupsListPresenter.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol SplitTestGroupsListPresenterProtocol {
    func presentGroups(response: SplitTestGroupsList.ShowGroups.Response)
}

final class SplitTestGroupsListPresenter: SplitTestGroupsListPresenterProtocol {
    weak var viewController: SplitTestGroupsListViewControllerProtocol?

    func presentGroups(response: SplitTestGroupsList.ShowGroups.Response) {
        let viewModel: SplitTestGroupsList.ShowGroups.ViewModel = {
            if response.groups.isEmpty {
                return .init(state: .emptyResult)
            } else {
                let viewModels = response.groups.map { group in
                    SplitTestGroupViewModel(
                        uniqueIdentifier: group.uniqueIdentifier,
                        title: group.uniqueIdentifier.capitalized,
                        isChecked: group.isCurrent
                    )
                }
                return .init(state: .result(data: viewModels))
            }
        }()

        self.viewController?.displayGroups(viewModel: viewModel)
    }
}
