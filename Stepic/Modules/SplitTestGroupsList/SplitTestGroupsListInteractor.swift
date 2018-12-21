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

        self.presenter.presentGroups(response: .init(groups: groups))
    }
}
