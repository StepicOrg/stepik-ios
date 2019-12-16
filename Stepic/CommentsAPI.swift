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

    func retrieve(ids: [Comment.IdType]) -> Promise<[Comment]> {
        Promise { seal in
            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                ids: ids,
                updating: [Comment](),
                withManager: self.manager
            ).done { comments, json in
                var userInfoByID = [Int: UserInfo]()
                json[Comment.JSONKey.users.rawValue].arrayValue.forEach {
                    let user = UserInfo(json: $0)
                    userInfoByID[user.id] = user
                }

                var voteByID = [Vote.IdType: Vote]()
                json[Comment.JSONKey.votes.rawValue].arrayValue.forEach {
                    let vote = Vote(json: $0)
                    voteByID[vote.id] = vote
                }

                for comment in comments {
                    comment.userInfo = userInfoByID[comment.userID]
                    comment.vote = voteByID[comment.voteID]
                }

                seal.fulfill(comments)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func create(_ comment: Comment) -> Promise<Comment> {
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

                seal.fulfill(comment)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func update(_ comment: Comment) -> Promise<Comment> {
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
