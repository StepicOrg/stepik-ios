//
//  AdaptiveSubmissionsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire

class AdaptiveSubmissionsAPI: SubmissionsAPI {
    override var url: String {
        return StepicApplicationsInfo.adaptiveRatingURL
    }

    fileprivate var additionalParams: Parameters {
        return ["course": StepicApplicationsInfo.adaptiveCourseId, "user": AuthInfo.shared.userId ?? 0]
    }

    override func retrieve(stepName: String, submissionId: Int, params: Parameters = [:], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Submission) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        var mutableParams = additionalParams
        params.forEach { k, v in mutableParams[k] = v }
        return super.retrieve(stepName: stepName, submissionId: submissionId, params: mutableParams, headers: headers, success: success, error: errorHandler)
    }

    override func retrieve(stepName: String, stepId: Int, isDescending: Bool? = true, page: Int? = 1, userId: Int? = nil, params: Parameters = [:], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Submission], Meta) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        var mutableParams = additionalParams
        params.forEach { k, v in mutableParams[k] = v }
        return super.retrieve(stepName: stepName, stepId: stepId, isDescending: isDescending, page: page, userId: userId, params: mutableParams, headers: headers, success: success, error: errorHandler)
    }

    override func retrieve(stepName: String, attemptId: Int, isDescending: Bool? = true, page: Int? = 1, userId: Int? = nil, params: Parameters = [:], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Submission], Meta) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        var mutableParams = additionalParams
        params.forEach { k, v in mutableParams[k] = v }
        return super.retrieve(stepName: stepName, attemptId: attemptId, isDescending: isDescending, page: page, userId: userId, params: mutableParams, headers: headers, success: success, error: errorHandler)
    }

    override func create(stepName: String, attemptId: Int, reply: Reply, params: Parameters = [:], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Submission) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        var mutableParams = additionalParams
        params.forEach { k, v in mutableParams[k] = v }
        return super.create(stepName: stepName, attemptId: attemptId, reply: reply, params: mutableParams, headers: headers, success: success, error: errorHandler)
    }
}
