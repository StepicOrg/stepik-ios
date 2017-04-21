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

class CommentsAPI {
    let name = "comments"
    
    @discardableResult func retrieve(_ ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Comment]) -> Void, error errorHandler: @escaping (String) -> Void) -> Request {
        let idsString = ApiUtil.constructIdsString(array: ids)
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)?\(idsString)", headers: headers).responseSwiftyJSON(
            {
                response in
                
                var error = response.result.error
                var json : JSON = [:]
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
                
                let comments : [Comment] = json["comments"].arrayValue.flatMap{
                    return Comment(json: $0)
                }
                
                var usersDict : [Int : UserInfo] = [Int: UserInfo]()
                
                json["users"].arrayValue.forEach{
                    let user = UserInfo(json: $0)
                    usersDict[user.id] = user
                }
                
                var votesDict : [String: Vote] = [String: Vote]()
                
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
    
    @discardableResult func create(_ comment: CommentPostable, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Comment) -> Void, error errorHandler: @escaping (String) -> Void) -> Request {
        let params: Parameters = [
            "comment" : comment.json
        ]
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON(
            {
                response in
                
                var error = response.result.error
                var json : JSON = [:]
                if response.result.value == nil {
                    if error == nil {
                        error = NSError()
                    }
                } else {
                    json = response.result.value!
                }
                let response = response.response
                
                if let e = error as NSError? {
                    errorHandler("CREATE comments: error \(e.domain) \(e.code): \(e.localizedDescription)")
                    return
                }
                
                if response?.statusCode != 201 {
                    errorHandler("CREATE comments: bad response status code \(String(describing: response?.statusCode))")
                    return
                }

                let comment : Comment = Comment(json: json["comments"].arrayValue[0])
                let userInfo = UserInfo(json: json["users"].arrayValue[0])
                let vote = Vote(json: json["votes"].arrayValue[0])
                comment.userInfo = userInfo
                comment.vote = vote
                
                success(comment)
            }
        )
    }
}

struct UserInfo {
    var id: Int
    var avatarURL: String
    var firstName: String
    var lastName: String
    init(json: JSON) {
        id = json["id"].intValue
        avatarURL = json["avatar"].stringValue
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
    }
    
    init(sample: Bool) {
        id = 10
        avatarURL = "http://google.com/"
        firstName = "Sample"
        lastName = "User"
    }
}
