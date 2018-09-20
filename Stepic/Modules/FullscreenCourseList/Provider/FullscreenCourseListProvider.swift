//
//  FullscreenCourseListFullscreenCourseListProvider.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol FullscreenCourseListProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]>
}

final class FullscreenCourseListProvider: FullscreenCourseListProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]> {
        return Promise<[Any]> { seal in
            seal.fulfill(["" as! Any])
        }
    }
}
