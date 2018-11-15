//
//  CourseInfoTabInfoProvider.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoTabInfoProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]>
}

final class CourseInfoTabInfoProvider: CourseInfoTabInfoProviderProtocol {
    func fetchSomeItems() -> Promise<[Any]> {
        return Promise<[Any]> { seal in
            seal.fulfill([""])
        }
    }
}
