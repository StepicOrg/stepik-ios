//
//  AdaptiveRatingsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class AdaptiveRatingsAPI: APIEndpoint {
    override var name: String { return "rating" }

    typealias RatingRecord = (userId: Int, exp: Int, rank: Int)
    typealias Scoreboard = (allCount: Int, leaders: [RatingRecord])

    func update(courseId: Int, exp: Int) -> Promise<Void> {
        var params: Parameters = [
            "course": courseId,
            "exp": exp
        ]

        if let token = AuthInfo.shared.token?.accessToken {
            params["token"] = token
        }

        return Promise { fulfill, reject in
            manager.request("\(RemoteConfig.shared.adaptiveBackendUrl)/\(name)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: nil).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    reject(error)
                case .success(_):
                    switch response.response?.statusCode ?? 500 {
                    case 200: fulfill()
                    case 401: reject(RatingsAPIError.badRequest)
                    default: reject(RatingsAPIError.serverError)
                    }
                }
            }
        }
    }

    func retrieve(courseId: Int, count: Int = 10, days: Int? = 7) -> Promise<Scoreboard> {
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

        return Promise { fulfill, reject in
            manager.request("\(StepicApplicationsInfo.adaptiveRatingURL)/\(name)", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    reject(error)
                case .success(let json):
                    if response.response?.statusCode == 200 {
                        let leaders = json["users"].arrayValue.map { RatingRecord(userId: $0["user"].intValue, exp: $0["exp"].intValue, rank: $0["rank"].intValue) }
                        fulfill(Scoreboard(allCount: json["count"].intValue, leaders: leaders))
                    } else {
                        reject(RatingsAPIError.serverError)
                    }
                }
            }
        }
    }
}

enum RatingsAPIError: Error {
    case badRequest, serverError, connectionError(error: String)
}
