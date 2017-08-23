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
    let name = "rating"

    typealias RatingRecord = (userId: Int, exp: Int, rank: Int)
    typealias Scoreboard = (allCount: Int, leaders: [RatingRecord])

    enum UpdateRatingResponse {
        case ok, badRequest, serverError, connectionError(error: String)
    }

    @discardableResult func update(courseId: Int, exp: Int, success: @escaping (UpdateRatingResponse) -> Void, error errorHandler: @escaping (UpdateRatingResponse) -> Void) -> Request? {
        var params: Parameters = [
            "course": courseId,
            "exp": exp
        ]
        if let token = AuthInfo.shared.token?.accessToken {
            params["token"] = token
        }

        return Alamofire.request("\(StepicApplicationsInfo.adaptiveRatingURL)/\(name)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: nil).responseSwiftyJSON({ response in
            var error = response.result.error
            if response.result.value == nil {
                if error == nil {
                    error = NSError(domain: "", code: -1, userInfo: nil)
                }
            }
            let response = response.response

            if let e = error as NSError? {
                errorHandler(.connectionError(error: "PUT adaptive rating: error \(e.domain) \(e.code): \(e.localizedDescription)"))
                return
            }

            switch response?.statusCode ?? 500 {
            case 200: success(.ok)
            case 401: errorHandler(.badRequest)
            default: errorHandler(.serverError)
            }
        })
    }

    @discardableResult func retrieve(courseId: Int, count: Int = 10, days: Int? = 7, success: @escaping (Scoreboard) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

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

        return Alamofire.request("\(StepicApplicationsInfo.adaptiveRatingURL)/\(name)", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseSwiftyJSON({ response in

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
}
