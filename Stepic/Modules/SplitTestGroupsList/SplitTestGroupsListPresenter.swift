//
//  SplitTestGroupsListSplitTestGroupsListPresenter.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

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
                let groups = self.formattedGroups(response.groups)
                return .init(state: .result(data: groups))
            }
        }()

        self.viewController?.displayGroups(viewModel: viewModel)
    }

    private func formattedGroups(_ groups: [String]) -> [SplitTestGroupViewModel] {
        return []
    }
}
