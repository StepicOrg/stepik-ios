//
//  ExploreExploreProvider.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExploreProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]>
}

final class ExploreProvider: ExploreProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]> {
        return Promise<[Any]> { seal in
            seal.fulfill(["" as! Any])
        }
    }
}
