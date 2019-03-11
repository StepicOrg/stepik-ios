//
//  LessonsNetworkService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol LessonsNetworkServiceProtocol: class {
    func fetch(ids: [Lesson.IdType]) -> Promise<[Lesson]>
}

final class LessonsNetworkService: LessonsNetworkServiceProtocol {
    private let lessonsAPI: LessonsAPI

    init(lessonsAPI: LessonsAPI) {
        self.lessonsAPI = lessonsAPI
    }

    func fetch(ids: [Lesson.IdType]) -> Promise<[Lesson]> {
        return Promise { seal in
            self.lessonsAPI.retrieve(ids: ids).done { lessons in
                let lessons = lessons.reordered(order: ids, transform: { $0.id })
                seal.fulfill(lessons)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
