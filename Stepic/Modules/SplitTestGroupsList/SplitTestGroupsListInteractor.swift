//
//  SplitTestGroupsListSplitTestGroupsListInteractor.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol SplitTestGroupsListInteractorProtocol {
    func getGroups(request: SplitTestGroupsList.ShowGroups.Request)
    func selectGroup(request: SplitTestGroupsList.SelectGroup.Request)
}

final class SplitTestGroupsListInteractor: SplitTestGroupsListInteractorProtocol {
    let presenter: SplitTestGroupsListPresenterProtocol
    let provider: SplitTestGroupsListProviderProtocol

    private let splitTestUniqueIdentifier: UniqueIdentifierType

    init(
        presenter: SplitTestGroupsListPresenterProtocol,
        provider: SplitTestGroupsListProviderProtocol,
        splitTestUniqueIdentifier: UniqueIdentifierType
    ) {
        self.presenter = presenter
        self.provider = provider
        self.splitTestUniqueIdentifier = splitTestUniqueIdentifier
    }

    func getGroups(request: SplitTestGroupsList.ShowGroups.Request) {
        let groups = self.getGroups()
        self.presenter.presentGroups(response: .init(groups: groups))
    }

    func selectGroup(request: SplitTestGroupsList.SelectGroup.Request) {
        self.provider.setGroup(
            request.viewModelUniqueIdentifier,
            splitTestUniqueIdentifier: self.splitTestUniqueIdentifier
        )

        let groups = self.getGroups()
        self.presenter.presentGroupChange(response: .init(groups: groups))
    }

    private func getGroups() -> [SplitTestGroupsList.Group] {
        let currentGroup = self.provider.getCurrentGroup(
            splitTestUniqueIdentifier: self.splitTestUniqueIdentifier
        )
        let groups = self.provider.getGroups(
            splitTestUniqueIdentifier: self.splitTestUniqueIdentifier
        ).map { group in
            SplitTestGroupsList.Group(
                uniqueIdentifier: group,
                isCurrent: group == currentGroup
            )
        }

        return groups
    }
}
