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
    func presentGroupChange(response: SplitTestGroupsList.SelectGroup.Response)
}

final class SplitTestGroupsListPresenter: SplitTestGroupsListPresenterProtocol {
    weak var viewController: SplitTestGroupsListViewControllerProtocol?

    func presentGroups(response: SplitTestGroupsList.ShowGroups.Response) {
        self.viewController?.displayGroups(
            viewModel: .init(state: self.getNewState(groups: response.groups))
        )
    }

    func presentGroupChange(response: SplitTestGroupsList.SelectGroup.Response) {
        self.viewController?.displayGroupChange(
            viewModel: .init(state: self.getNewState(groups: response.groups))
        )
    }

    private func getNewState(
        groups: [SplitTestGroupsList.Group]
    ) -> SplitTestGroupsList.ViewControllerState {
        if groups.isEmpty {
            return .emptyResult
        } else {
            let viewModels = groups.map { group in
                SplitTestGroupViewModel(
                    uniqueIdentifier: group.uniqueIdentifier,
                    title: group.uniqueIdentifier.capitalized,
                    isChecked: group.isCurrent
                )
            }
            return .result(data: viewModels)
        }
    }
}
