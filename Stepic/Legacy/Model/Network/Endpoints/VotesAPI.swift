//
//  VotesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class VotesAPI: APIEndpoint {
    override class var name: String { "votes" }

    func update(_ vote: Vote) -> Promise<Vote> {
        self.update.request(
            requestEndpoint: Self.name,
            paramName: "vote",
            updatingObject: vote,
            withManager: self.manager
        )
    }
}

extension VotesAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    func update(_ vote: Vote, success: @escaping ((Vote) -> Void), error errorHandler: @escaping ((String) -> Void)) {
        self.update(vote)
            .done { success($0) }
            .catch { errorHandler($0.localizedDescription) }
    }
}
