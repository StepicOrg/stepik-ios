//
// Created by Ivan Magda on 03/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProgressService {
    /// Method is used to fetch progresses using API request.
    ///
    /// - Parameters:
    ///   - ids: Ids to fetch.
    ///   - refreshMode: Request refresh mode: `update` or `delete`.
    /// - Returns: Promise with an array of `ProgressPlainObject` objects.
    func fetchProgresses(
        with ids: [String],
        refreshMode: RefreshMode
    ) -> Promise<[ProgressPlainObject]>
    /// Method is used to obtain progresses from cache.
    ///
    /// - Parameter ids: Ids to fetch.
    /// - Returns: Promise with an array of `Progress` objects from cache.
    func obtainProgresses(with ids: [String]) -> Promise<[ProgressPlainObject]>
}

extension ProgressService {
    func fetchProgresses(with ids: [String]) -> Promise<[ProgressPlainObject]> {
        return fetchProgresses(with: ids, refreshMode: .update)
    }
}
