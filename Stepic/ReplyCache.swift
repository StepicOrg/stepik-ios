//
//  ReplyCache.swift
//  Stepic
//
//  Created by Ostrenkiy on 17.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class ReplyCache {
    typealias ReplyForAttempt = (reply: Reply?, attemptId: Int)

    static var shared = ReplyCache()

    private init() { }

    private var replyByStepID: [Int: ReplyForAttempt] = [:]

    private func resetCache() {
        self.replyByStepID = [:]
    }

    func set(reply: Reply?, forStepId id: Int, attemptId: Int) {
        self.replyByStepID[id] = (reply: reply, attemptId: attemptId)
    }

    func getReply(forStepId id: Int, attemptId: Int) -> Reply? {
        let replyForAttempt = self.replyByStepID[id]
        if replyForAttempt?.attemptId == attemptId {
            return replyForAttempt?.reply
        } else {
            return nil
        }
    }
}
