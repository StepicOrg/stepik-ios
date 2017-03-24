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
    static let name = "recommendations"
    
    @discardableResult static func getRecommendedLessonId(courseId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Int) -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request {
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(RecommendationsAPI.name)?course=\(courseId)", headers: headers).responseSwiftyJSON(
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
                    errorHandler("GetRecommendedLesson: no recommendations")
                    return
                }
                
                success(lessonId)
                
                return
            }
        )
    }

    enum Reaction: Int {
        case complicated = 0
        case simple = -1
        case done = 2
    }
}
