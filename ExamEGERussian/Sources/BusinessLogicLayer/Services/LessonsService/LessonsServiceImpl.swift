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
        return fetchLessons(ids: ids).mapValues {
            LessonPlainObject(lesson: $0)
        }
    }

    func obtainLessons(with ids: [Int]) -> Promise<[LessonPlainObject]> {
        return executeFetchRequest(ids: ids).mapValues {
            LessonPlainObject(lesson: $0)
        }
    }

    func fetchProgress(id: Int, stepsService: StepsService) -> Promise<Double> {
        return fetchLessons(ids: [id]).firstValue.then { lesson in
            stepsService.fetchProgresses(stepsIds: lesson.stepsArray)
        }.then { steps -> Promise<Double> in
            .value(self.computeProgress(steps: steps))
        }
    }

    func fetchProgresses(ids: [Int], stepsService: StepsService) -> Promise<[Double]> {
        let progressesToFetch = ids.map { fetchProgress(id: $0, stepsService: stepsService) }
        return when(fulfilled: progressesToFetch).then { progresses -> Promise<[Double]> in
            .value(progresses)
        }
    }

    func obtainProgress(id: Int, stepsService: StepsService) -> Guarantee<Double> {
        return Guarantee { seal in
            executeFetchRequest(ids: [id]).firstValue.then { lesson in
                stepsService.obtainSteps(with: lesson.stepsArray)
            }.done { steps in
                seal(self.computeProgress(steps: steps))
            }.catch { error in
                print("Failed obtain progress for lesson with id: \(id), error: \(error)")
                seal(0)
            }
        }
    }

    func obtainProgresses(ids: [Int], stepsService: StepsService) -> Guarantee<[Double]> {
        return Guarantee { seal in
            let progressesToObtain = ids.map { obtainProgress(id: $0, stepsService: stepsService) }
            when(fulfilled: progressesToObtain).done { progresses in
                seal(progresses)
            }.catch { error in
                print("Failed fetch progresses with error: \(error)")
                seal(Array(repeating: 0, count: ids.count))
            }
        }
    }

    // MARK: - Private API

    private func fetchLessons(ids: [Int]) -> Promise<[Lesson]> {
        return executeFetchRequest(ids: ids).then {
            self.lessonsAPI.retrieve(ids: ids, existing: $0)
        }
    }

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

    private func computeProgress(steps: [StepPlainObject]) -> Double {
        guard steps.count > 0 else {
            return 0
        }

        let countPassed = steps.filter { $0.isPassed }.count

        return Double(countPassed) / Double(steps.count)
    }
}
