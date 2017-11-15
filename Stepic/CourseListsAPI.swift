//
//  CourseListsAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class CourseListsAPI: APIEndpoint {
    override var name: String {
        return "course-lists"
    }

    @discardableResult func retrieve(language: ContentLanguage, page: Int = 1, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<([CourseList], Meta)> {
        let params : Parameters = [
            "platform": "mobile",
            "language": language.languageString,
            "page": page
        ]

        return Promise<([CourseList], Meta)> {
            fulfill, reject in
            manager.request("\(StepicApplicationsInfo.apiURL)/\(name)", method: .get, parameters: params, headers: headers).validate().responseSwiftyJSON { response in
                switch response.result {

                case .failure(let error):
                    reject(RetrieveError(error: error))

                case .success(let json):
                    let meta = Meta(json: json["meta"])
                    //TODO: Better make this recovery-update mechanism more generic to avoid code duplication. Think about it.
                    let jsonArray: [JSON] = json["course-lists"].array ?? []
                    let listIds: [Int] = jsonArray.map {
                        $0["id"].intValue
                    }
                    let recoveredLists = CourseList.recover(ids: listIds)
                    let resultArray: [CourseList] = jsonArray.map {
                        objectJSON in
                        if let recoveredIndex = recoveredLists.index(where: { $0.hasEqualId(json: objectJSON) }) {
                            recoveredLists[recoveredIndex].update(json: objectJSON)
                            return recoveredLists[recoveredIndex]
                        } else {
                            return CourseList(json: objectJSON)
                        }
                    }

                    CoreDataHelper.instance.save()
                    fulfill((resultArray, meta))
                }
            }
        }
    }
}
