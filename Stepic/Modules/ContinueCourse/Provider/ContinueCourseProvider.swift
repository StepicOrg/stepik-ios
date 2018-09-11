//
//  ContinueCourseContinueCourseProvider.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol ContinueCourseProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]>
}

final class ContinueCourseProvider: ContinueCourseProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]> {
        return Promise<[Any]> { seal in
            seal.fulfill(["" as! Any])
        }
    }
}