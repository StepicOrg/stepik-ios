//
//  TagsTagsProvider.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol TagsProviderProtocol {
    func fetchTags() -> Guarantee<[CourseTag]>
}

final class TagsProvider: TagsProviderProtocol {
    func fetchTags() -> Guarantee<[CourseTag]> {
        return Guarantee { seal in
            seal(CourseTag.featuredTags)
        }
    }
}
