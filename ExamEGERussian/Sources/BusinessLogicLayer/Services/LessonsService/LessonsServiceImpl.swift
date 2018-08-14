//
//  LessonsServiceImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

final class LessonsServiceImpl: LessonsService {
    private let lessonsAPI: LessonsAPI

    init(lessonsAPI: LessonsAPI) {
        self.lessonsAPI = lessonsAPI
    }

    func fetchLessons(with ids: [Int]) -> Promise<[LessonPlainObject]> {
        return executeFetchRequest(ids: ids).then {
            self.lessonsAPI.retrieve(ids: ids, existing: $0)
        }.mapValues {
            self.toPlainObject($0)
        }
    }

    func obtainLessons(with ids: [Int]) -> Promise<[LessonPlainObject]> {
        return executeFetchRequest(ids: ids).mapValues {
            self.toPlainObject($0)
        }
    }

    // MARK: - Private API

    private func executeFetchRequest(ids: [Int]) -> Promise<[Lesson]> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Lesson.self))
        let descriptor = NSSortDescriptor(key: "managedId", ascending: true)

        let idPredicates = ids.map { NSPredicate(format: "managedId == %@", $0 as NSNumber) }
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        request.predicate = predicate
        request.sortDescriptors = [descriptor]

        return Promise<[Lesson]> { seal in
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request, completionBlock: { results in
                guard let lessons = results.finalResult as? [Lesson] else {
                    seal.fulfill([])
                    return
                }
                seal.fulfill(lessons)
            })
            _ = try? CoreDataHelper.instance.context.execute(asyncRequest)
        }
    }

    private func toPlainObject(_ lesson: Lesson) -> LessonPlainObject {
        return LessonPlainObject(id: lesson.id, steps: lesson.stepsArray, title: lesson.title, slug: lesson.slug)
    }
}
