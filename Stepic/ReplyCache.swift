//
//  ReplyCache.swift
//  Stepic
//
//  Created by Ostrenkiy on 17.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class ReplyCache {

    static var shared = ReplyCache()

    typealias ReplyForAttempt = (reply: Reply?, attemptId: Int)

    private init() {}

    private var replyForStepId: [Int: ReplyForAttempt] = [:]

    private func resetCache() {
        replyForStepId = [:]
    }

    func set(reply: Reply?, forStepId id: Int, attemptId: Int) {
        replyForStepId[id] = (reply: reply, attemptId: attemptId)
    }

    func getReply(forStepId id: Int, attemptId: Int) -> Reply? {
        let replyForAttempt = replyForStepId[id]
        if replyForAttempt?.attemptId == attemptId {
            return replyForAttempt?.reply
        } else {
            return nil
        }
    }
}
