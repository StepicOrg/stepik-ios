//
//  ProgressesNetworkService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 30.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProgressesNetworkServiceProtocol: class {
    func fetch(ids: [Progress.IdType], page: Int) -> Promise<([Progress], Meta)>
    func fetch(id: Progress.IdType) -> Promise<Progress?>
}

final class ProgressesNetworkService: ProgressesNetworkServiceProtocol {
    private let progressesAPI: ProgressesAPI

    init(progressesAPI: ProgressesAPI) {
        self.progressesAPI = progressesAPI
    }

    func fetch(ids: [Progress.IdType], page: Int = 1) -> Promise<([Progress], Meta)> {
        // FIXME: We have no pagination here but should support it
        return Promise { seal in
            self.progressesAPI.retrieve(ids: ids).done { progresses in
                let progresses = progresses.reordered(order: ids, transform: { $0.id })
                seal.fulfill((progresses, Meta.oneAndOnlyPage))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Progress.IdType) -> Promise<Progress?> {
        return Promise { seal in
            self.progressesAPI.retrieve(ids: [id]).done { progresses in
                seal.fulfill(progresses.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
