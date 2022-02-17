//
//  LastStepsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

final class LastStepsAPI: APIEndpoint {
    override class var name: String { "last-steps" }

    @discardableResult
    func retrieve(
        ids: [String],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        updatingLastSteps: [LastStep],
        success: @escaping (([LastStep]) -> Void),
        error errorHandler: @escaping ((NetworkError) -> Void)
    ) -> Request? {
        self.getObjectsByIds(
            requestString: Self.name,
            printOutput: false,
            ids: ids,
            deleteObjects: updatingLastSteps,
            refreshMode: .update,
            success: success,
            failure: errorHandler
        )
    }
}
