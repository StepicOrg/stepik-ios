//
//  StepsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class StepsAPI: APIEndpoint {
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    override class var name: String { "steps" }

    init(stepsPersistenceService: StepsPersistenceServiceProtocol = StepsPersistenceService()) {
        self.stepsPersistenceService = stepsPersistenceService
        super.init()
    }

    func retrieve(
        ids: [Int],
        existing: [Step],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders
    ) -> Promise<[Step]> {
        self.getObjectsByIds(ids: ids, updating: existing, printOutput: false)
    }

    @available(*, deprecated, message: "Legacy: we want to pass existing")
    func retrieve(ids: [Int], headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders) -> Promise<[Step]> {
        if ids.isEmpty {
            return .value([])
        }

        return self.stepsPersistenceService.fetch(ids: ids).then { cachedSteps in
            self.getObjectsByIds(ids: ids, updating: cachedSteps)
        }
    }
}

extension StepsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func retrieve(
        ids: [Int],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        existing: [Step],
        refreshMode: RefreshMode,
        success: @escaping ([Step]) -> Void,
        error errorHandler: @escaping (NetworkError) -> Void
    ) -> Request? {
        self.retrieve(ids: ids, existing: existing, headers: headers)
            .done { success($0) }
            .catch { errorHandler(NetworkError(error: $0)) }
        return nil
    }
}
