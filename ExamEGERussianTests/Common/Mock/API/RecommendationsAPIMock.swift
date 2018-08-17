//
//  RecommendationsAPIMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 17/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class RecommendationsAPIMock: RecommendationsAPI, PromiseReturnable {
    var resultToBeReturned: Promise<[Int]> = Promise(error: NSError.mockError)

    override func retrieve(course courseId: Int, count: Int, headers: [String : String]) -> Promise<[Int]> {
        return resultToBeReturned
    }
}
