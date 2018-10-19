//
//  ApiRequest.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

enum PerformRequestError: Error {
    case noAccessToRefreshToken, other, badConnection
}

func checkToken() -> Promise<()> {
    return Promise { seal in
        ApiRequestPerformer.performAPIRequest({
            seal.fulfill(())
        }, error: { error in
            seal.reject(error)
        })
    }
}

//Should preferrably be called from a UIViewController subclass
func performRequest(_ request: @escaping (() -> Void), error: ((PerformRequestError) -> Void)? = nil) {
    ApiRequestPerformer.performAPIRequest(request, error: error)
}

class ApiRequestPerformer {

    static let semaphore = DispatchSemaphore(value: 1)
    static let queue = DispatchQueue(label: "perform_request_queue", qos: DispatchQoS.background)

    static func performAPIRequest(_ completion: @escaping (() -> Void), error errorHandler: ((PerformRequestError) -> Void)? = nil) {

        let completionWithSemaphore : () -> Void = {
            if EnvironmentVariable.isStepikApiDebugLogEnabled {
                print("finished performing API Request")
            }
            semaphore.signal()
            DispatchQueue.main.async {
                completion()
            }
        }

        let errorHandlerWithSemaphore: (PerformRequestError) -> Void = {
            error in
            if EnvironmentVariable.isStepikApiDebugLogEnabled {
                print("finished performing API Request")
            }
            semaphore.signal()
            DispatchQueue.main.async {
                errorHandler?(error)
            }
        }

        queue.async {
            semaphore.wait()

            if EnvironmentVariable.isStepikApiDebugLogEnabled {
                print("performing API request")
            }

            if !AuthInfo.shared.hasUser {
                print("no user in AuthInfo, retrieving")
                ApiDataDownloader.stepics.retrieveCurrentUser(success: {
                    user in
                    AuthInfo.shared.user = user
                    User.removeAllExcept(user)
                    print("retrieved current user")
                    performRequestWithAuthorizationCheck(completionWithSemaphore, error: errorHandlerWithSemaphore)
                }, error: { e in
                    if let typedError = e as? URLError {
                        switch typedError.code {
                        case .notConnectedToInternet:
                            errorHandlerWithSemaphore(.badConnection)
                        default:
                            errorHandlerWithSemaphore(.other)
                        }
                    } else {
                        errorHandlerWithSemaphore(.other)
                    }
                })
            } else {
                performRequestWithAuthorizationCheck(completionWithSemaphore, error: errorHandlerWithSemaphore)
            }
        }
    }

    fileprivate static func performRequestWithAuthorizationCheck(_ completion: @escaping (() -> Void), error errorHandler: ((PerformRequestError) -> Void)? = nil) {

//        if let user = AuthInfo.shared.user {
//            print("performing request with user \(user.id)")
        if !AuthInfo.shared.isAuthorized && Session.needsRefresh {
            _ = Session.refresh(completion: {
                    completion()
                }, error: {
                    _ in
                    errorHandler?(.other)
                }
            )
            return
        }

        if AuthInfo.shared.isAuthorized && AuthInfo.shared.needsToRefreshToken {
            if let refreshToken = AuthInfo.shared.token?.refreshToken {
                ApiDataDownloader.auth.refreshTokenWith(refreshToken, success: {
                        t in
                        AuthInfo.shared.token = t
                        completion()
                    }, failure : {
                        error in
                        print("error while auto refresh token")
                        if error == TokenRefreshError.noAccess {
                            errorHandler?(.noAccessToRefreshToken)
                        } else {
                            errorHandler?(.other)
                        }
                    }
                )
                return
            } else {
                    //No token to refresh with authorized user
                errorHandler?(.other)
                return
            }
        }

        completion()
    }

}
