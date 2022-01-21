//
//  StepikURLSessionConfiguration.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.04.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation

final class StepikURLSessionConfiguration: URLSessionConfiguration {
    override class var `default`: URLSessionConfiguration {
        let configuration = super.default
        configuration.timeoutIntervalForRequest = APIDefaults.Configuration.timeoutIntervalForRequest

        let headers = HTTPHeaders([.stepikUserAgent])
        configuration.httpAdditionalHeaders = headers.dictionary

        return configuration
    }
}
