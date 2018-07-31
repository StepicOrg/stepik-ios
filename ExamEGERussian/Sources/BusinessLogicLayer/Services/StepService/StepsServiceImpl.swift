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

    init(stepsAPI: StepsAPI) {
        self.stepsAPI = stepsAPI
    }

    func fetchSteps(with ids: [Int]) -> Promise<[StepPlainObject]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        return firstly {
            executeFetchRequest(ids: ids)
        }.then {
            self.stepsAPI.retrieve(ids: ids, existing: $0)
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

    // MARK: - Private API

    private func executeFetchRequest(ids: [Int]) -> Promise<[Step]> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Step.self))
        let descriptor = NSSortDescriptor(key: "managedId", ascending: true)

        let idPredicates = ids.map { NSPredicate(format: "managedId == %@", $0 as NSNumber) }
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
            type: type ?? .text
        )
    }
}
