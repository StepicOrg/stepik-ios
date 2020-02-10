//
//  CommentsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CommentsAPI: APIEndpoint {
    override var name: String { "comments" }

    /// Get comments by ids.
    ///
    /// - Parameter ids: The identifiers array of the comments to fetch.
    /// - Parameter blockName: The name of the step's block (see Block.BlockType) for parsing reply and dataset.
    /// - Returns: A promise with an array comments.
    func retrieve(ids: [Comment.IdType], blockName: String?) -> Promise<[Comment]> {
        Promise { seal in
            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                ids: ids,
                updating: [Comment](),
                withManager: self.manager
            ).done { comments, json in
                var userInfoByUserID = [User.IdType: UserInfo]()
                json[Comment.JSONKey.users.rawValue].arrayValue.forEach {
                    let user = UserInfo(json: $0)
                    userInfoByUserID[user.id] = user
                }

                var voteByID = [Vote.IdType: Vote]()
                json[Comment.JSONKey.votes.rawValue].arrayValue.forEach {
                    let vote = Vote(json: $0)
                    voteByID[vote.id] = vote
                }

                let isBlockNameProvided = !(blockName?.isEmpty ?? true)

                let attempts = json[Comment.JSONKey.attempts.rawValue].arrayValue.map {
                    isBlockNameProvided
                        ? Attempt(json: $0, stepName: blockName ?? "")
                        : Attempt(json: $0)
                }

                var submissionByID = [Submission.IdType: Submission]()
                json[Comment.JSONKey.submissions.rawValue].arrayValue.forEach {
                    let submission = isBlockNameProvided
                        ? Submission(json: $0, stepName: blockName ?? "")
                        : Submission(json: $0)

                    if let attempt = attempts.first(where: { $0.id == submission.attemptID }) {
                        submission.attempt = attempt
                    }

                    submissionByID[submission.id] = submission
                }

                for comment in comments {
                    comment.userInfo = userInfoByUserID[comment.userID]
                    comment.vote = voteByID[comment.voteID]

                    if let submissionID = comment.submissionID {
                        comment.submission = submissionByID[submissionID]
                    }
                }

                seal.fulfill(comments)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func create(_ comment: Comment, blockName: String?) -> Promise<Comment> {
        Promise { seal in
            self.create.request(
                requestEndpoint: self.name,
                paramName: "comment",
                creatingObject: comment,
                withManager: self.manager
            ).done { comment, json in
                let userInfo = UserInfo(json: json[Comment.JSONKey.users.rawValue].arrayValue[0])
                let vote = Vote(json: json[Comment.JSONKey.votes.rawValue].arrayValue[0])

                comment.userInfo = userInfo
                comment.vote = vote

                let isBlockNameProvided = !(blockName?.isEmpty ?? true)

                let attempts = json[Comment.JSONKey.attempts.rawValue].arrayValue.map {
                    isBlockNameProvided
                        ? Attempt(json: $0, stepName: blockName ?? "")
                        : Attempt(json: $0)
                }

                var submissionByID = [Submission.IdType: Submission]()
                json[Comment.JSONKey.submissions.rawValue].arrayValue.forEach {
                    let submission = isBlockNameProvided
                        ? Submission(json: $0, stepName: blockName ?? "")
                        : Submission(json: $0)

                    if let attempt = attempts.first(where: { $0.id == submission.attemptID }) {
                        submission.attempt = attempt
                    }

                    submissionByID[submission.id] = submission
                }

                if let submissionID = comment.submissionID {
                    comment.submission = submissionByID[submissionID]
                }

                seal.fulfill(comment)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func update(_ comment: Comment, blockName: String?) -> Promise<Comment> {
        Promise { seal in
            self.update.request(
                requestEndpoint: self.name,
                paramName: "comment",
                updatingObject: comment,
                withManager: self.manager
            ).done { comment, json in
                let userInfo = UserInfo(json: json[Comment.JSONKey.users.rawValue].arrayValue[0])
                let vote = Vote(json: json[Comment.JSONKey.votes.rawValue].arrayValue[0])

                comment.userInfo = userInfo
                comment.vote = vote

                let isBlockNameProvided = !(blockName?.isEmpty ?? true)

                let attempts = json[Comment.JSONKey.attempts.rawValue].arrayValue.map {
                    isBlockNameProvided
                        ? Attempt(json: $0, stepName: blockName ?? "")
                        : Attempt(json: $0)
                }

                var submissionByID = [Submission.IdType: Submission]()
                json[Comment.JSONKey.submissions.rawValue].arrayValue.forEach {
                    let submission = isBlockNameProvided
                        ? Submission(json: $0, stepName: blockName ?? "")
                        : Submission(json: $0)

                    if let attempt = attempts.first(where: { $0.id == submission.attemptID }) {
                        submission.attempt = attempt
                    }

                    submissionByID[submission.id] = submission
                }

                if let submissionID = comment.submissionID {
                    comment.submission = submissionByID[submissionID]
                }

                seal.fulfill(comment)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func delete(commentID: Comment.IdType) -> Promise<Void> {
        self.delete.request(requestEndpoint: self.name, deletingId: commentID, withManager: self.manager)
    }
}
