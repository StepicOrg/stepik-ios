//
//  CourseListPersistenceService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseListPersistenceServiceProtocol: class {
    func fetch() -> Promise<[Course]>
    func update(newCachedList: [Course])
}

final class CourseListPersistenceService: CourseListPersistenceServiceProtocol {
    let type: PersistableCourseListTypeProtocol

    init(type: PersistableCourseListTypeProtocol) {
        self.type = type
    }

    func fetch() -> Promise<[Course]> {
        let courseListIDs = self.type.storage.getCoursesList()

        return Promise { seal in
            Course.fetchAsync(courseListIDs).done { courses in
                seal.fulfill(courses)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func update(newCachedList: [Course]) {
        let ids = newCachedList.map { $0.id }
        self.type.storage.update(newCachedList: ids)
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
