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

class RatingsAPI {

    typealias RatingRecord = (userId: Int, exp: Int, rank: Int)

    @discardableResult func retrieve(courseId: Int, count: Int = 10, days: Int? = 7, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([RatingRecord]) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

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
                let leaders = json.arrayValue.map({return RatingRecord(userId: $0["user"].intValue, exp: $0["exp"].intValue, rank: $0["rank"].intValue)})
                success(leaders)
                return
            } else {
                errorHandler("Response status code is wrong(\(String(describing: response?.statusCode)))")
                return
            }
        })
    }
}
