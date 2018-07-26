//
//  LessonsServiceImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

final class LessonsServiceImpl: LessonsService {
    private struct Response: Codable {
        let lessons: [LessonPlainObject]
    }

    func fetchLessons(with ids: [Int]) -> Promise<[LessonPlainObject]> {
        let url = "\(StepicApplicationsInfo.apiURL)/lessons"
        let parameters = ["ids": ids]
        let headers = AuthInfo.shared.initialHTTPHeaders

        return firstly {
            Alamofire
                .request(url, parameters: parameters, headers: headers)
                .responseDecodable(Response.self)
        }.then { response in
            Promise.value(response.lessons)
        }
    }
}
