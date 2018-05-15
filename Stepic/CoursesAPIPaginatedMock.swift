//
//  CoursesAPIPaginatedMock.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire

class CoursesAPIPaginatedMock: CoursesAPI {
    @discardableResult override func retrieve(ids: [Int], headers: [String : String], existing: [Course], refreshMode: RefreshMode, success: @escaping (([Course]) -> Void), error errorHandler: @escaping ((NetworkError) -> Void)) -> Request? {
        success(ids.map({
            let c = Course()
            c.id = $0
            c.title = "Course #\($0)"
            return c
        }))
        return nil
    }
}
