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
        return Promise {
            fulfill, reject in
            retrieve.request(requestEndpoint: "comments", paramName: "comments", ids: ids, updating: Array<Comment>(), withManager: manager).then {
                comments, json -> Void in
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
                fulfill(comments)
            }.catch {
                error in
                reject(error)
            }
        }
    }

    @discardableResult func retrieve(_ ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Comment]) -> Void, error errorHandler: @escaping (String) -> Void) -> Request {
        let idsString = ApiUtil.constructIdsString(array: ids)
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)?\(idsString)", headers: headers).responseSwiftyJSON({
                response in

                var error = response.result.error
                var json: JSON = [:]
                if response.result.value == nil {
                    if error == nil {
                        error = NSError()
                    }
                } else {
                    json = response.result.value!
                }
                let response = response.response

                if let e = error as NSError? {
                    errorHandler("RETRIEVE comments: error \(e.localizedDescription)")
                    return
                }

                if response?.statusCode != 200 {
                    errorHandler("RETRIEVE comments: bad response status code \(String(describing: response?.statusCode))")
                    return
                }

                let comments: [Comment] = json["comments"].arrayValue.flatMap {
                    Comment(json: $0)
                }

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

                success(comments)
            }
        )
    }

    func create(_ comment: Comment) -> Promise<Comment> {
        return Promise { fulfill, reject in
            create.request(requestEndpoint: "comments", paramName: "comment", creatingObject: comment, withManager: manager).then {
                comment, json -> Void in
                guard let json = json else {
                    fulfill(comment)
                    return
                }
                let userInfo = UserInfo(json: json["users"].arrayValue[0])
                let vote = Vote(json: json["votes"].arrayValue[0])
                comment.userInfo = userInfo
                comment.vote = vote
                fulfill(comment)
            }.catch {
                error in
                reject(error)
            }
        }
    }
}

extension CommentsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func create(_ comment: Comment, success: @escaping (Comment) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        create(comment).then { success($0) }.catch { errorHandler($0.localizedDescription) }
        return nil
    }
}
