//
//  ApiRequest.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

enum PerformRequestError: Error {
    case noAccessToRefreshToken, other, badConnection
}

func checkToken() -> Promise<()> {
    Promise { seal in
        ApiRequestPerformer.performAPIRequest({
            seal.fulfill(())
        }, error: { error in
            seal.reject(error)
        })
    }
}

// Should preferably be called from a UIViewController subclass
func performRequest(_ request: @escaping () -> Void, error: ((PerformRequestError) -> Void)? = nil) {
    ApiRequestPerformer.performAPIRequest(request, error: error)
}

final class ApiRequestPerformer {
    private static let semaphore = DispatchSemaphore(value: 1)
    private static let queue = DispatchQueue(label: "perform_request_queue", qos: .userInitiated)

    fileprivate static func performAPIRequest(
        _ completion: @escaping () -> Void,
        error errorHandler: ((PerformRequestError) -> Void)? = nil
    ) {
        let completionWithSemaphore: () -> Void = {
            self.debugLog("finished performing API Request")
            semaphore.signal()
            DispatchQueue.main.async {
                completion()
            }
        }

        let errorHandlerWithSemaphore: (PerformRequestError) -> Void = { error in
            self.debugLog("finished performing API Request")
            semaphore.signal()
            DispatchQueue.main.async {
                errorHandler?(error)
            }
        }

        queue.async {
            semaphore.wait()
            self.debugLog("performing API request")

            if AuthInfo.shared.hasUser {
                performRequestWithAuthorizationCheck(completionWithSemaphore, error: errorHandlerWithSemaphore)
            } else {
                self.debugLog("no user in AuthInfo, retrieving")
                ApiDataDownloader.stepics.retrieveCurrentUser(
                    success: { user in
                        AuthInfo.shared.user = user
                        User.removeAllExcept(user)
                        self.debugLog("retrieved current user")
                        performRequestWithAuthorizationCheck(completionWithSemaphore, error: errorHandlerWithSemaphore)
                    },
                    error: { error in
                        self.debugLog("failed retrieve current user")
                        if let typedError = error as? URLError {
                            switch typedError.code {
                            case .notConnectedToInternet:
                                errorHandlerWithSemaphore(.badConnection)
                            default:
                                errorHandlerWithSemaphore(.other)
                            }
                        } else {
                            errorHandlerWithSemaphore(.other)
                        }
                    }
                )
            }
        }
    }

    private static func performRequestWithAuthorizationCheck(
        _ completion: @escaping () -> Void,
        error errorHandler: ((PerformRequestError) -> Void)? = nil
    ) {
        if !AuthInfo.shared.isAuthorized && StepikSession.needsRefresh {
            _ = StepikSession.refresh(
                completion: {
                    completion()
                },
                error: { _ in
                    errorHandler?(.other)
                }
            )
            return
        }

        if AuthInfo.shared.isAuthorized && AuthInfo.shared.needsToRefreshToken {
            guard let refreshToken = AuthInfo.shared.token?.refreshToken else {
                // No token to refresh with authorized user
                errorHandler?(.other)
                return
            }

            ApiDataDownloader.auth.refreshTokenWith(
                refreshToken,
                success: { token in
                    self.debugLog("refresh token auto refreshed")
                    AuthInfo.shared.token = token
                    completion()
                },
                failure: { error in
                    self.debugLog("error while auto refresh token")
                    if error == TokenRefreshError.noAccess {
                        errorHandler?(.noAccessToRefreshToken)
                    } else {
                        errorHandler?(.other)
                    }
                }
            )
            return
        }

        completion()
    }

    private static func debugLog(_ message: StaticString) {
        if LaunchArguments.isNetworkDebuggingEnabled {
            print("ApiRequestPerformer :: \(message)")
        }
    }
}
