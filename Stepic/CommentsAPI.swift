//
//  CommentsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class CommentsAPI: APIEndpoint {
    override var name: String { return "comments" }

    func retrieve(ids: [Int]) -> Promise<[Comment]> {
        return Promise { seal in
            retrieve.request(requestEndpoint: "comments", paramName: "comments", ids: ids, updating: Array<Comment>(), withManager: manager).done { comments, json in
                var usersDict: [Int : UserInfo] = [Int: UserInfo]()

                json["users"].arrayValue.forEach {
                    let user = UserInfo(json: $0)
                    usersDict[user.id] = user
                }

                var votesDict: [String: Vote] = [String: Vote]()

                json["votes"].arrayValue.forEach({
                    let vote = Vote(json: $0)
                    votesDict[vote.id] = vote
                })

                for comment in comments {
                    comment.userInfo = usersDict[comment.userId]
                    comment.vote = votesDict[comment.voteId]
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
