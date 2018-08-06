//
//  StepsServiceImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

final class StepsServiceImpl: StepsService {
    private let stepsAPI: StepsAPI
    private let progressService: ProgressService

    init(stepsAPI: StepsAPI, progressService: ProgressService) {
        self.stepsAPI = stepsAPI
        self.progressService = progressService
    }

    func fetchSteps(with ids: [Int]) -> Promise<[StepPlainObject]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        return firstly {
            fetchSteps(ids: ids)
        }.mapValues {
            self.toPlainObject($0)
        }
    }

    func obtainSteps(with ids: [Int]) -> Promise<[StepPlainObject]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        return executeFetchRequest(ids: ids).mapValues {
            self.toPlainObject($0)
        }
    }

    func fetchProgresses(stepsIds ids: [Int]) -> Promise<[StepPlainObject]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        var steps = [Step]()
        var solvedMap = [Int: Bool]()

        return executeFetchRequest(ids: ids).then { cachedSteps -> Promise<[Progress]> in
            steps = cachedSteps
            let progressesIds = steps.compactMap {
                $0.progressId
            }
            steps.forEach {
                solvedMap[$0.id] = $0.progress?.isPassed ?? false
            }

            return self.progressService.fetchProgresses(with: progressesIds)
        }.then { progresses -> Promise<[Step]> in
            progresses.forEach { progress in
                guard let step = steps.filter({ $0.progressId == progress.id }).first else {
                    return
                }
                progress.isPassed = solvedMap[step.id] ?? false
                step.progress = progress
            }
            CoreDataHelper.instance.save()

            return .value(steps)
        }.mapValues {
            self.toPlainObject($0)
        }
    }

    func markAsSolved(stepsIds ids: [Int]) -> Promise<[StepPlainObject]> {
        return executeFetchRequest(ids: ids).then { steps -> Promise<[Step]> in
            steps.forEach { step in
                step.progress?.isPassed = true
            }
            CoreDataHelper.instance.save()

            return .value(steps)
        }.mapValues {
            self.toPlainObject($0)
        }
    }

    // MARK: - Private API

    func fetchSteps(ids: [Int]) -> Promise<[Step]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        return firstly {
            executeFetchRequest(ids: ids)
        }.then {
            self.stepsAPI.retrieve(ids: ids, existing: $0)
        }
    }

    private func executeFetchRequest(ids: [Int]) -> Promise<[Step]> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Step.self))
        let descriptor = NSSortDescriptor(key: "managedId", ascending: true)

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        request.predicate = predicate
        request.sortDescriptors = [descriptor]

        return Promise<[Step]> { seal in
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request, completionBlock: { results in
                guard let steps = results.finalResult as? [Step] else {
                    seal.fulfill([])
                    return
                }
                seal.fulfill(steps)
            })
            _ = try? CoreDataHelper.instance.context.execute(asyncRequest)
        }
    }

    private func toPlainObject(_ step: Step) -> StepPlainObject {
        let type = StepPlainObject.StepType(rawValue: step.block.name)
        if type == nil {
            print("Receive undefined step type: \(step.block.name)")
        }

        return StepPlainObject(
            id: step.id,
            lessonId: step.lessonId,
            position: step.position,
            text: step.block.text ?? "",
            type: type ?? .text,
            progressId: step.progressId,
            isPassed: step.progress?.isPassed ?? false
        )
    }
}
