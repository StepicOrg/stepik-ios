//
//  AdaptiveCoursesInfoAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import Alamofire

typealias AdaptiveCourseInfo = (id: Int, title: String, coverURL: String, description: String, firstColor: UIColor, secondColor: UIColor, mainColor: UIColor)

class AdaptiveCoursesInfoAPI: APIEndpoint {
    let fileNamePrefix = "courses_"

    func retrieve(locale: String) -> Promise<[AdaptiveCourseInfo]> {
        return Promise { fulfill, reject in
            manager.request("\(RemoteConfig.shared.adaptiveCoursesInfoUrl)/\(fileNamePrefix)\(locale).json").responseData { response in
                switch response.result {
                case .failure(_):
                    reject(AdaptiveCourseInfoAPIError.retrieve)
                case .success(let data):
                    if response.response?.statusCode == 200 {
                        let json = JSON(data)
                        print(json)
                        let info = json["courses"].arrayValue.map {
                            AdaptiveCourseInfo(id: $0["id"].intValue,
                                title: $0["title"].stringValue,
                                coverURL: $0["cover"].stringValue,
                                description: $0["description"].stringValue,
                                firstColor: UIColor(hex: $0["first_color"].intValue),
                                secondColor: UIColor(hex: $0["second_color"].intValue),
                                mainColor: UIColor(hex: $0["main_color"].intValue))
                        }
                        fulfill(info)
                    } else {
                        reject(AdaptiveCourseInfoAPIError.badRequest)
                    }
                }
            }
        }
    }
}

enum AdaptiveCourseInfoAPIError: Error {
    case retrieve, badRequest
}
