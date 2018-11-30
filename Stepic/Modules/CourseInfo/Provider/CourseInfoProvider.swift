//
//  CourseInfoCourseInfoProvider.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]>
}

final class CourseInfoProvider: CourseInfoProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]> {
        return Promise<[Any]> { seal in
            seal.fulfill(["" as! Any])
        }
    }
}
