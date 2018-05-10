//
//  ErrorEnums.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire

enum FetchError: Error {
    case requestExecution
}


enum WeakSelfError: Error {
    case noStrong
}

//Is used for handling errors in network requests
enum NetworkError: Error {
    case badStatus(Int)
    case noConnection
    case timedOut
    case cancelled
    case other(Error)

    private init(AFError error: AFError) {
        if error.isCancelledError {
            self = .cancelled
            return
        }
        if error.isResponseValidationError {
            if (error.underlyingError as NSError?)?.code == -6003 {
                if let badCode = error.responseCode {
                    self = .badStatus(badCode)
                    return
                }
            }
        }

        self = .other(error)
        AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.unknownNetworkError, parameters: ["aferror":"\(error.errorDescription ?? "")"])
    }

    private init(NSError error: NSError) {
        switch error.code {
        case -999: self = .cancelled
        case -1009: self = .noConnection
        case -1001: self = .timedOut
        default:
            print("tried to construct unknown error")
            self = .other(error)
            AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.unknownNetworkError, parameters: ["nserror":" code: \(error.code), description: \(error.localizedDescription)"])
        }
    }

    init(error: Error) {
        if let afError = error as? AFError {
            self.init(AFError: afError)
            return
        }
        self.init(NSError: error as NSError)
    }
}

//Is used for handling errors in data parsing
enum ParsingError: Error {
    case badData
}

//Is used for handling unwrapping errors. Mostly useful in promises
enum UnwrappingError: Error {
    case optionalError
}

//Is used for handling
enum DatabaseError: Error {
    case fetchFailed
}
