//
//  ReactionsAPIMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 17/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class ReactionsAPIMock: RecommendationsAPI {
    var resultToBeReturned: Promise<Void> = Promise(error: NSError.mockError)

    override func sendReaction(user userId: Int, lesson lessonId: Int, reaction: Reaction, headers: [String : String]) -> Promise<Void> {
        return resultToBeReturned
    }
}
