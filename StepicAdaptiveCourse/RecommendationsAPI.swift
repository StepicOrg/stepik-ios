//
//  RecommendationsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RecommendationsAPI {
    let name = "recommendations"
    let reactionName = "recommendation-reactions"
    
    @discardableResult func getRecommendedLessonId(course courseId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Int?) -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request {
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(self.name)?course=\(courseId)", headers: headers).responseSwiftyJSON(
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
                
                if let e = error as? NSError {
                    errorHandler("GetRecommendedLesson: error \(e.localizedDescription)")
                    return
                }
                
                if response?.statusCode != 200 {
                    errorHandler("GetRecommendedLesson: bad response status code \(response?.statusCode)")
                    return
                }
                
                let lessonIds = json["recommendations"].arrayValue.map({ $0["lesson"].intValue })
                
                guard let lessonId = lessonIds.first else {
                    success(nil)
                    return
                }
                
                success(lessonId)
                
                return
            }
        )
    }
    
    // TODO: should we pass reaction/lessonId to success handler?
    @discardableResult func sendRecommendationReaction(user userId: Int, lesson lessonId: Int, reaction: Reaction, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Void) -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request {
        let params = [
            "recommendationReaction": [
                "reaction": reaction.rawValue,
                "lesson": lessonId,
                "user": userId
            ]
        ]
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(self.reactionName)", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON(
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
                
                if let e = error as? NSError {
                    errorHandler("SendRecommendationReaction: error \(e.localizedDescription)")
                    return
                }
                
                if response?.statusCode != 201 {
                    errorHandler("SendRecommendationReaction: bad response status code \(response?.statusCode)")
                    return
                }
                
                let recommendationReactions = json["recommendation-reactions"]
                
                guard recommendationReactions.count != 0 else {
                    errorHandler("SendRecommendationReaction: reaction not confirmed")
                    return
                }
                
                success()
                
                return
            }
        )
    }
}

enum Reaction: Int {
    case solved = 2
    case interesting = 1
    case maybeLater = 0
    case neverAgain = -1
}
