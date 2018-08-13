//
// Created by Ivan Magda on 03/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

final class ProgressServiceImpl: ProgressService {
    private let progressesAPI: ProgressesAPI

    init(progressesAPI: ProgressesAPI) {
        self.progressesAPI = progressesAPI
    }

    func fetchProgresses(with ids: [String], refreshMode: RefreshMode) -> Promise<[Progress]> {
        return executeFetchRequest(ids: ids).then { cachedProgresses in
            self.fetchProgresses(with: ids, existing: cachedProgresses, refreshMode: refreshMode)
        }
    }

    func obtainProgresses(with ids: [String]) -> Promise<[Progress]> {
        return executeFetchRequest(ids: ids)
    }

    // MARK: - Private API

    private func executeFetchRequest(ids: [String]) -> Promise<[Progress]> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Progress.self))
        let descriptor = NSSortDescriptor(key: "managedId", ascending: true)

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0)
        }
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        request.predicate = predicate
        request.sortDescriptors = [descriptor]

        return Promise<[Progress]> { seal in
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request, completionBlock: { results in
                guard let progresses = results.finalResult as? [Progress] else {
                    seal.fulfill([])
                    return
                }
                seal.fulfill(progresses)
            })
            _ = try? CoreDataHelper.instance.context.execute(asyncRequest)
        }
    }

    private func fetchProgresses(with ids: [String], existing: [Progress], refreshMode: RefreshMode) -> Promise<[Progress]> {
        return Promise { seal in
            progressesAPI.retrieve(
                ids: ids,
                existing: existing,
                refreshMode: refreshMode,
                success: { progresses in
                    seal.fulfill(progresses)
                },
                error: { error in
                    seal.reject(error)
                }
            )
        }
    }
}
