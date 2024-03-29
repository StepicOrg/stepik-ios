//
//  AdaptiveRatingsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class AdaptiveRatingsAPI: APIEndpoint {
    override class var name: String { "rating" }

    typealias RatingRecord = (userId: Int, exp: Int, rank: Int, isFake: Bool)
    typealias Scoreboard = (allCount: Int, leaders: [RatingRecord])

    func update(courseId: Int, exp: Int) -> Promise<Void> {
        var params: Parameters = [
            "course": courseId,
            "exp": exp
        ]

        if let token = AuthInfo.shared.token?.accessToken {
            params["token"] = token
        }

        return Promise { seal in
            self.manager.request(
                "\(RemoteConfig.shared.adaptiveBackendURL)/\(Self.name)",
                method: .put,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: nil
            ).responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    seal.reject(error)
                case .success:
                    switch response.response?.statusCode ?? 500 {
                    case 200: seal.fulfill(())
                    case 401: seal.reject(RatingsAPIError.badRequest)
                    default: seal.reject(RatingsAPIError.serverError)
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

        return Promise { seal in
            self.manager.request(
                "\(RemoteConfig.shared.adaptiveBackendURL)/\(Self.name)",
                method: .get,
                parameters: params,
                encoding: URLEncoding.default,
                headers: nil
            ).validate().responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    seal.reject(error)
                case .success(let json):
                    let leaders = json["users"]
                        .arrayValue
                        .map {
                            RatingRecord(
                                userId: $0["user"].intValue,
                                exp: $0["exp"].intValue,
                                rank: $0["rank"].intValue,
                                isFake: !$0["is_not_fake"].boolValue
                            )
                        }
                    let scoreboard = Scoreboard(
                        allCount: json["count"].intValue,
                        leaders: leaders
                    )
                    seal.fulfill(scoreboard)
                }
            }
        }
    }
}

enum RatingsAPIError: Error {
    case badRequest, serverError, connectionError(error: String)
}
