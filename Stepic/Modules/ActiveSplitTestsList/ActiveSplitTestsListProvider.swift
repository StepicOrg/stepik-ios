//
//  ActiveSplitTestsListProvider.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

protocol ActiveSplitTestsListProviderProtocol {
    func getActiveSplitTests() -> [ActiveSplitTestsList.SplitTest]
}

final class ActiveSplitTestsListProvider: ActiveSplitTestsListProviderProtocol {
    func getActiveSplitTests() -> [ActiveSplitTestsList.SplitTest] {
        return ActiveSplitTestsContainer.activeSplitTestsInfo.map { key, splitTestInfo in
            .init(
                uniqueIdentifier: key,
                title: splitTestInfo.title
            )
        }
    }
}
