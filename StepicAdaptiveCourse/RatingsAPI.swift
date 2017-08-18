//
//  RatingsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension ApiDataDownloader {
    static let adaptiveRatings = RatingsAPI()
}

class RatingsAPI {

    typealias RatingRecord = (userId: Int, exp: Int, rank: Int)
    typealias Scoreboard = (allCount: Int, leaders: [RatingRecord])

    @discardableResult func retrieve(courseId: Int, count: Int = 10, days: Int? = 7, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Scoreboard) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

        var params: Parameters = [
            "course": courseId,
            "count": count
        ]
        if let days = days {
            params["days"] = days
        }
        if let userId = AuthInfo.shared.userId {
            params["user"] = userId
        }

        return Alamofire.request("\(StepicApplicationsInfo.adaptiveRatingURL)/rating", method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
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

            if let e = error {
                let d = (e as NSError).localizedDescription
                print(d)
                errorHandler(d)
                return
            }

            if response?.statusCode == 200 {
                let leaders = json["users"].arrayValue.map({return RatingRecord(userId: $0["user"].intValue, exp: $0["exp"].intValue, rank: $0["rank"].intValue)})
                success(Scoreboard(allCount: json["count"].intValue, leaders: leaders))
                return
            } else {
                errorHandler("Response status code is wrong(\(String(describing: response?.statusCode)))")
                return
            }
        })
    }

    @discardableResult func migrate(courseId: Int, exp: Int, streak: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Bool) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

        var params: Parameters = [
            "course": courseId,
            "exp": exp,
            "streak": streak
        ]
        if let userId = AuthInfo.shared.userId {
            params["user"] = userId
        }

        return Alamofire.request("\(StepicApplicationsInfo.adaptiveRatingURL)/migrate", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({
            response in

            var error = response.result.error
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            }
            let response = response.response

            if let e = error {
                let d = (e as NSError).localizedDescription
                print(d)
                errorHandler(d)
                return
            }

            if response?.statusCode == 200 || response?.statusCode == 201 {
                success(response?.statusCode == 201)
                return
            } else {
                errorHandler("Response status code is wrong(\(String(describing: response?.statusCode)))")
                return
            }
        })
    }
}
