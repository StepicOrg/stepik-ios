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
    override var name: String { return "comments" }

    func retrieve(ids: [Comment.IdType]) -> Promise<[Comment]> {
        return Promise { seal in
            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                ids: ids,
                updating: Array<Comment>(),
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
        return Promise { seal in
            create.request(requestEndpoint: "comments", paramName: "comment", creatingObject: comment, withManager: manager).done { comment, json in
                guard let json = json else {
                    seal.fulfill(comment)
                    return
                }
                let userInfo = UserInfo(json: json["users"].arrayValue[0])
                let vote = Vote(json: json["votes"].arrayValue[0])
                comment.userInfo = userInfo
                comment.vote = vote
                seal.fulfill(comment)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}

extension CommentsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func create(_ comment: Comment, success: @escaping (Comment) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        create(comment).done { success($0) }.catch { errorHandler($0.localizedDescription) }
        return nil
    }

    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func retrieve(_ ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Comment]) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        retrieve(ids: ids).done { comments in
            success(comments)
        }.catch { error in
            errorHandler(error.localizedDescription)
        }
        return nil
    }
}
